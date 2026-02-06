import express from "express";
import bodyParser from "body-parser";
import cors from "cors";
import fs from "fs-extra";
import path from "path";
import { fileURLToPath } from "url";
import { v4 as uuidv4 } from "uuid";
import multer from "multer"; //add drag-drop image



const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// !!! 중요 !!!
// 컨테이너 안에서는 /app/posts 가 글 저장 폴더야.
// 이 경로는 Docker에서 NAS의 /volume1/blog_posts 와 연결해줄 거야.
const POSTS_DIR = path.join(__dirname, "posts");
const ASSETS_DIR = process.env.ASSETS_DIR || path.join(__dirname, "assets");// image
const upload = multer({
        dest: path.join(ASSETS_DIR, "_tmp"), // temporary saving foler
        limits: { fileSize: 100 * 1024 * 1024 } // limit  100MB
})

const CATEGORIES_FILE = path.join(__dirname, "categories.json");



// 간단한 토큰 보안 (너만 아는 비번)
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || "qwerhh33";

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use("/media", express.static(ASSETS_DIR));
// app.use("/assets", express.static(ASSETS_DIR));

// serve the static file.
// when image is  uploaded using "/api/upload" , it use service into "/assets/xxx.ext" automatically.
//


async function readCategories() {
        try {
                const raw = await fs.readFile(CATEGORIES_FILE, "utf8");
                const list = JSON.parse(raw);
                if(Array.isArray(list)) return list;
                return [];
        } catch(e) {
                return [];
        }

}

async function writeCategories(list) {
        await fs.writeFile(
                CATEGORIES_FILE,
                JSON.stringify(list,null,2),
                "utf8",
        );

}





// 글 파일 하나의 구조:
// --- front matter 비슷한 JSON ---
// { "id": "...", "title": "...", "created_at": "...", "tags": [...] }
// --- 빈 줄 ---
// (여기부터 마크다운 본문)

// Nas 서버(Node.js)에서 게시글 목록을 ㅁ나들어서 반환하기 위한 함수
async function listPosts() {
  const files = await fs.readdir(POSTS_DIR);
  const posts = [];

  for (const filename of files) {
    if (!filename.endsWith(".md")) continue;
    const fullPath = path.join(POSTS_DIR, filename);
    const raw = await fs.readFile(fullPath, "utf8");

    // 첫 줄부터 메타데이터(JSON) 한 줄만 읽게 설계하자
    // 예:
    // {"id":"...","title":"...","created_at":"...","tags":["..."]}
    const firstNewline = raw.indexOf("\n");
    if (firstNewline === -1) continue;

    const metaJsonStr = raw.substring(0, firstNewline).trim();
    try {
      const meta = JSON.parse(metaJsonStr); //meta: 파싱한 결과 객체
      posts.push({
        id: meta.id,
        title: meta.title,
        created_at: meta.created_at,
        tags: meta.tags || [],
        category: meta.category || null,  //new field
        thumbnail: meta.thumbnail || null, 
        status: meta.status || "public",
      });
    } catch (e) {
      console.warn("failed to parse meta in", filename, e);
    }
  }

  // 최신 순 정렬 (created_at 기반으로 정렬 시도)
  posts.sort((a, b) => {
    return (b.created_at || "").localeCompare(a.created_at || "");
  });

  return posts;
}

async function readPost(id) {
  const filePath = path.join(POSTS_DIR, `${id}.md`);
  if (!(await fs.pathExists(filePath))) {
    return null;
  }
  const raw = await fs.readFile(filePath, "utf8");
  const firstNewline = raw.indexOf("\n");
  if (firstNewline === -1) {
    return { meta: null, body: raw };
  }

  const metaJsonStr = raw.substring(0, firstNewline).trim();
  const bodyMarkdown = raw.substring(firstNewline + 1);

  let meta = null;
  try {
    meta = JSON.parse(metaJsonStr);
  } catch (e) {
    console.warn("failed to parse meta for", id, e);
  }

  return {
    meta,
    body: bodyMarkdown
  };
}

async function writePost({ title, body_markdown, tags, category, thumbnail, status }) {
  const now = new Date().toISOString(); // "2025-11-01T13:45:00.123Z" 이런 식
  const id = uuidv4(); // 예: "2e2c1e73-..."
  const meta = {
    id,
    title,
    created_at: now,
    tags: tags || [],
    category: category || null,
    thumbnail: thumbnail || null, 
    status : status || "public",
  };

  const fileContent = JSON.stringify(meta) + "\n" + body_markdown;
  const filePath = path.join(POSTS_DIR, `${id}.md`);

  await fs.writeFile(filePath, fileContent, "utf8");

  return meta;
}

/*기존글 파일을 부분 수정(patch)하고 다시 저장 -> 업데이트된 메타 정보를 반환함. */
async function updatePost(id, patch) {
  const filePath = path.join(POSTS_DIR, `${id}.md`);
  if(!(await fs.pathExists(filePath))) return null;
  //해당 파일이 있는지 확인 -> 없으면 null 반환


  const raw = await fs.readFile(filePath, "utf8");
  //파일 전체를 문자열로 읽어오기
  const firstNewline = raw.indexOf("\n");
  //"\n"로 시작하는 첫째줄 위치 찾기.
  let meta = {};
  let body = raw;

  /*첫줄 아닌 줄은 meta쪽과 본문body로 나눈다. */
  //줄 바꿈이 있으면 메타 1줄 +본문 분리
  if(firstNewline !== -1) {
    const metaJsonStr = raw.substring(0, firstNewline).trim();
    body = raw.substring(firstNewline +1);
    try {
      meta= JSON.parse(metaJsonStr);
    } catch(_) {
      meta = {};
    }
  }
  /*id/created_at */
  //이미 존재하면 유지, 없으면 새로 생성,
   const newMeta= {
    ...meta,
    id: meta.id || id,
    //함수인자로 id받음. 
    created_at:meta.created_at || new Date().toISOString(),
   };

   /*patch에 있는 것만 메타에 덮어씌우기 */
   if(patch.title != null) newMeta.title = patch.title;
   if(patch.tags != null) newMeta.tags = patch.tags;
   if(patch.category !== undefined) newMeta.category = patch.category; // null 허용
   if(patch.thumbnail !== undefined) newMeta.thumbnail = patch.thumbnail; // null 허용
   if(patch.status !== undefined) newMeta.status = patch.status; 

   const newBody = (patch.body_markdown != null) ? patch.body_markdown : body;

   const fileContent = JSON.stringify(newMeta) + "\n" + newBody;
   //첫줄 : 메타 JSON
   // 그 다음 본문 markdown
   await fs.writeFile(filePath,fileContent, "utf8");
   //파일을 통째로 다시 씀(덮어쓰기)

   return newMeta;
   //업데이트 된 메타 반환

}


// 1) 글 목록
app.get("/api/posts", async (req, res) => {
  try {
    const posts = await listPosts();
    res.json(posts);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "failed_to_list_posts" });
  }
});

// 2) 특정 글 읽기 (마크다운 반환)
app.get("/api/posts/:id", async (req, res) => {
  try {
    const id = req.params.id;
    const post = await readPost(id);
    if (!post) {
      return res.status(404).json({ error: "not_found" });
    }

    // Flutter에서 markdown 그대로 받아서 렌더할거면 body만 줘도 되고,
    // 웹에서 바로 쓸거면 meta도 같이 주자.
    res.json({
      meta: post.meta,
      body_markdown: post.body
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "failed_to_read_post" });
  }
});

// 3) 글 작성(업로드) - 보호 필요!
// thumbnail 받아서 넘기기
// process
// post publish in flutter client  -> store this contents using this "api" in server.
app.post("/api/posts", async (req, res) => {
  try {
    // 아주 간단한 보안: 헤더 확인
    const token = req.header("X-ADMIN-TOKEN");
    //관리자만 글 작성 가능하도록,
    if (token !== ADMIN_TOKEN) {
      return res.status(401).json({ error: "unauthorized" });
    }

    const { title, body_markdown, tags, category, thumbnail, status} = req.body;
    if (!title || !body_markdown) {
      //필수 필드 검사
      return res.status(400).json({ error: "missing_fields" });
    }

    const meta = await writePost({ title, body_markdown, tags, category, thumbnail,status });
    //실제 저장 함수 호출
    res.json({ ok: true, post: meta });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "failed_to_write_post" });
  }
});


// 4) 카테고리 목록
app.get("/api/categories", async(req,res) => {

        try {
                const cats = await readCategories();
                res.json(cats);
        }
        catch(err)  {
                console.error(err);
                res.status(500).json({ error: "failed_to_list_categories"});

        }

});

// 5) 카테고리 추가 (관리자만)
// 라우트 등록 
app.post("/api/categories", async (req, res) => {
  try {
    const token = req.header("X-ADMIN-TOKEN"); //관리자 토큰 받기
    if (token !== ADMIN_TOKEN) {
      return res.status(401).json({ error: "unauthorized" });
    }

    /*요청 body에서 값 꺼내기 + 기본값 */
    const {name,parent_id = null, icon_key = null } = req.body; //icon이 key를 받을 수 있도록 추가. 
    //260204: const {name,parent_id = null} = req.body; 
    //body(json)에서 name,parent_id,icon_key를 꺼냄.  없을시 기본값 null
    //client는 {"name":"SLAM", "parent_id":null, "icon_key": "robot"} 이렇게 보냄. 
    const nameRaw = (name || "").trim(); //이름을 안전하게 정리.
    if (!nameRaw) {
      return res.status(400).json({ error: "name_required" });
      //이름 비어 있으면 요청이 잘못되었으니 400반환
    }

    const slug =
      nameRaw
        .toLowerCase()
        .replace(/\s+/g, "-")         // 공백 → -
        .replace(/[^a-z0-9-_]/g, "")  // 슬러그에 안 맞는 문자 제거
      || uuidv4();

    let cats = await readCategories(); 
    //categories.json 에서 카테고리 목록 읽어옴. 

    // 이름 중복 체크 (대소문자 무시)
    const exists = cats.find(
      (c) => c.name.toLowerCase() === nameRaw.toLowerCase(),
    );
    if (exists) {
      // 이미 있으면 그걸 돌려주고 끝
      return res.json({ ok: true, category: exists, existed: true });
    }

    const cat = {
      id: uuidv4(),
      name: nameRaw,
      slug,
      parent_id,
      icon_key: icon_key || null, //260205 추가
    };

    cats.push(cat);
    //새로운 카테고리니까 cats 배열에 저장하고 
    await writeCategories(cats);
    //categories.json에 쓰기

    res.json({ ok: true, category: cat });
    //카테고리 생성 알림. 
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "failed_to_create_category" });
  }
});


// 6)  rout for upload
app.post("/api/upload", upload.single("file"), async(req,res) => {
  try {
        const token = req.header("X-ADMIN-TOKEN");
        if(token !== ADMIN_TOKEN) {
          return res.status(401).json({error : "unauthorized"});
        }

        const file = req.file;
        if (!file){
                return res.status(400).json({ error: "no_file" });
        }

        // keep the source extension(jgp,mp4,png)
        const ext = path.extname(file.originalname) || "";
        const id = uuidv4();
        const finalName = id + ext;

        //final path :
        const finalPath = path.join(ASSETS_DIR, finalName);

        await fs.move(file.path, finalPath, { overwrite: true});
        // temporary saving path -> final saving path

        const publicUrl = `/media/${finalName}`;
        //업로드 파일은 /media로 노출

        res.json({
                ok: true,
                url: publicUrl,
                filename: finalName,
                ext
        });

  } catch (err){
          console.error(err);
          res.status(500).json({error: "upload_failed" });
  }

});

// 7) update
/// Express 서버에서 게시글 수정(PATCH) API를 만든 것
/// 관리자 토큰 확인 -> 글 업데이트 -> 결과 반환
/*
Client로부터 호출 예시 
fetch(`/api/posts/${id}`, {
  method: "PATCH",
  headers: {
    "Content-Type": "application/json",
    "X-ADMIN-TOKEN": ADMIN_TOKEN,
  },
  body: JSON.stringify({ title: "새 제목" }),
});

*/

app.patch("/api/posts/:id", async (req,res) => {
  //HTTP PATCH 라우트 등록
  try{
    const token = req.header("X-ADMIN-TOKEN");
    //관리자 권한 확인, 요청 헤더에서 X-ADMIN-TOKEN 읽음. 서버에 저장된 ADMIN_TOKEN과 같은지 확인 다르면 401
    if(token !== ADMIN_TOKEN) {
      return res.status(401).json({error: "unauthorized"});
    }

    const id = req.params.id;
    //URL에서 id값 가져오기.
    const {title, body_markdown, tags, category, thumbnail, status} = req.body;
    // body에서 수정할 값들 꺼내기.
    // 필드들을 구조 분해로 가져옴. 

    const meta = await updatePost(id, {title, body_markdown, tags, category,thumbnail, status});
    //실제 업데이트 진행
    if(!meta) return res.status(404).json({error: "not_found"});
    //글 없으면 404, upatePost 가 파일이 없으면 null 리턴하니까. 

    res.json({ok: true, post: meta});
    //성공 시 JSON으로 응답

  } catch (err) {
    console.error(err);
    res.status(500).json({ error:"failed_to_update_post"});
  }
});

// 8) 삭제 기능
app.delete("/api/posts/:id", async(req, res) => {
  try {
    const token = req.header("X-ADMIN-TOKEN");
    if(token !== ADMIN_TOKEN) {
      return res.status(401).json({error : "unauthorized"});
    }
    //토큰 확인 

    const id = req.params.id;
    const filePath = path.join(POSTS_DIR, `${id}.md`);
    //id로 글 있느지 확인

    if(!(await fs.pathExists(filePath))) {
      return res.status(404).json({error : "not_found"});
    }

    await fs.remove(filePath); //실제 파일 삭제
    res.json({ ok: true});
    //응답은 단순 ok

  } catch(err) {
    console.error(err) ;
    res.status(500).json({error: "failed_to_delete_post"});
  }
});


const PORT = process.env.PORT || 5000;

// 서버 시작 전에 posts 폴더 있는지 확인
fs.ensureDirSync(POSTS_DIR);
fs.ensureDirSync(ASSETS_DIR);
fs.ensureDirSync(path.join(ASSETS_DIR,"_tmp"));

app.listen(PORT, () => {
  console.log(`NAS Blog API running on port ${PORT}`);
});

