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
const ADMIN_TOKEN = process.env.ADMIN_TOKEN || "CHANGE_ME_PLEASE";

const app = express();
app.use(cors());
app.use(bodyParser.json());
app.use("/assets", express.static(ASSETS_DIR));
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

async function writePost({ title, body_markdown, tags, category, thumbnail }) {
  const now = new Date().toISOString(); // "2025-11-01T13:45:00.123Z" 이런 식
  const id = uuidv4(); // 예: "2e2c1e73-..."
  const meta = {
    id,
    title,
    created_at: now,
    tags: tags || [],
    category: category || null,
    thumbnail: thumbnail || null, 
  };

  const fileContent = JSON.stringify(meta) + "\n" + body_markdown;
  const filePath = path.join(POSTS_DIR, `${id}.md`);

  await fs.writeFile(filePath, fileContent, "utf8");

  return meta;
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

    const { title, body_markdown, tags, category, thumbnail} = req.body;
    if (!title || !body_markdown) {
      //필수 필드 검사
      return res.status(400).json({ error: "missing_fields" });
    }

    const meta = await writePost({ title, body_markdown, tags, category, thumbnail });
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
app.post("/api/categories", async (req, res) => {
  try {
    const token = req.header("X-ADMIN-TOKEN");
    if (token !== ADMIN_TOKEN) {
      return res.status(401).json({ error: "unauthorized" });
    }

    const {name,parent_id = null} = req.body;
    const nameRaw = (name || "").trim();
    if (!nameRaw) {
      return res.status(400).json({ error: "name_required" });
    }

    const slug =
      nameRaw
        .toLowerCase()
        .replace(/\s+/g, "-")         // 공백 → -
        .replace(/[^a-z0-9-_]/g, "")  // 슬러그에 안 맞는 문자 제거
      || uuidv4();

    let cats = await readCategories();

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
      parent_id
    };

    cats.push(cat);
    await writeCategories(cats);

    res.json({ ok: true, category: cat });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "failed_to_create_category" });
  }
});


// rout for upload
app.post("/api/upload", upload.single("file"), async(req,res) => {
        try {
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

                const publicUrl = `/assets/${finalName}`;

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


const PORT = process.env.PORT || 5000;

// 서버 시작 전에 posts 폴더 있는지 확인
fs.ensureDirSync(POSTS_DIR);
fs.ensureDirSync(ASSETS_DIR);
fs.ensureDirSync(path.join(ASSETS_DIR,"_tmp"));

app.listen(PORT, () => {
  console.log(`NAS Blog API running on port ${PORT}`);
});
