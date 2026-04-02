/*상태 + 이벤트 + 레이아웃만 */

import 'dart:math';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:nas_blog1/config/config.dart';
import 'package:nas_blog1/models/screen_model.dart';
import 'package:nas_blog1/services/upload_service.dart';
import 'package:nas_blog1/models/blog_category.dart';
import 'package:nas_blog1/services/post_service.dart';
import 'package:nas_blog1/services/category_service.dart';
import 'package:nas_blog1/ui/pages/editor/editor_center.dart';
import 'package:nas_blog1/utils/markdown/markdown_insert.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../models/post_status.dart';

import 'dialogs/image_option_dialog.dart';
import 'dialogs/preview_dialog.dart';

import 'widgets/editor_appbar.dart';
import 'widgets/editor_tools_panel.dart';
import 'widgets/publish_tools_panel.dart';
import 'dialogs/add_category_dialog.dart';


/// EditorPg
/// purpose
/// input
/// how it works
/// 
class EditorPg extends StatefulWidget {
  final String? post_id;
  const EditorPg({super.key, this.post_id});

  @override
  State<EditorPg> createState() => _EditorPgState();
}

class _EditorPgState extends State<EditorPg> {
  late final TextEditingController _title_ctrl;
  late final TextEditingController _body_ctrl;

  bool _is_saving = false;
  String? _error_msg;

  String? _thumbnail_rel_url;
  String? _thumbnail_full_url;

  List<BlogCategory> _categories_flat = [];
  String? _selected_category_slug;
  //null일수도 있음. 

  PostStatus _status = PostStatus.public;

@override
  void initState() {
    // TODO: implement initState
    super.initState();
    _title_ctrl = TextEditingController();
    _body_ctrl = TextEditingController();
    _fetchCategories();

    if(widget.post_id != null) {
      _loadExistingPost(widget.post_id!);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _title_ctrl.dispose();
    _body_ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final screen_model = _calcScreenModel(context);
    final screen_model = ScreenModel.of(context);
    final Widget editor_center = EditorCenter(
                                  title_ctrl: _title_ctrl,
                                  body_ctrl: _body_ctrl,
                                  error_msg: _error_msg
                              );
    final Widget public_tools_panel =  PublishToolsPanel(
                                          thumbnail_full_url: _thumbnail_full_url,
                                          on_pick_thumbnail: _onPickThumbnail, 
                                          on_remove_thumbnail: _onRemoveThumbnail, 
                                          status: _status, 
                                          on_change_status: _onChangeStatus,
                                          categories_flat: _categories_flat, 
                                          selected_category_slug: _selected_category_slug, 
                                          on_select_category: _onSelectCategory, 
                                          on_add_category: _onAddCategoryDialog);
    
    final padding = _calcPadding(screen_model);
    final gap = _calcGap(screen_model);
    
    return Scaffold(
      appBar: EditorAppBar(
        title: widget.post_id ==null 
                ? 'New Post' : 'Edit Post',
        is_saving: _is_saving,
        on_preview: _openPreview,
        on_save: _savePost,
      ),
      body: LayoutBuilder(
        //LayoutBuilder : 공간 제약을 런타임에 받아서 그 값에 따라 다른 레이아웃 선택하게 해줌.
        builder: (context,c) {          
          if(screen_model.web) {
            return  Padding(
              padding:  EdgeInsets.all(padding),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 220, 
                    child: EditorToolsPanel(
                      on_insert_image: _insertMediaIntoMarkdown,
                      on_insert_video: _insertMediaIntoMarkdown,
                    )
                  ),
                  SizedBox(width: gap),
                  Expanded(child: editor_center),
                  SizedBox(width: gap),
                  SizedBox(
                    width: 320,
                    child: public_tools_panel
                  )
                ]
              )
            );
          }
          /* mobile /tablet */
          return Padding(
            padding: EdgeInsets.all(padding),
            child: Column( //길게. 
              children: [
                EditorToolsPanel(
                  on_insert_image: _insertMediaIntoMarkdown, 
                  on_insert_video: _insertMediaIntoMarkdown
                ),
                SizedBox(height:gap),
                Expanded(child: editor_center),
                SizedBox(height:gap),
                if(screen_model.tablet) 
                  SizedBox(
                    width: 520,
                    child: public_tools_panel
                ) else 
                  public_tools_panel



              ]
            )
          );
        }
      )
    );
  }

  /*
  funcs 
  - _fetchCategories
  - _onAddCategoryDialog
  - _onPickThumbnail
  - _onRemoveThumbnail
  - _onChangeStatus
  - _onSelectCategory
  - _insertMediaIntoMarkdown
  - _savePost
  - _openPreview
  - _calcPadding
  - _calcGap
  - _loadExistingPost : 이미 존재하는 post를 load하기.


  */
  /*서버에서 카테고리 목록을 가져와서 state에 저장하고 UI를 갱신하는 함수 */
  //성공하면 목록 저장, 기본 선택값 세팅, 에러 제거
  //실패하면 애러 메시지 저장
  // 그 변화가 UI에 반영디도록 setState()호출
  Future<void> _fetchCategories() async {
    try {
      final  cats = await CategoryService.fetchCategories();
      if(!mounted) return; //화면이 아직 살아 있는지확인
      setState(() {
        _categories_flat = cats;
        if(_selected_category_slug == null && cats.isNotEmpty){
          _selected_category_slug = cats.first.slug;
        } 
        _error_msg =null;
        //성공했으니 애러 표시 제거,
      });
    } catch (e) {
      if(!mounted) return;
      setState(() => _error_msg = 'Category load error: $e');

    }
  }

/*새 카테고리 추가 다이얼로그 */
//목적: 값 반환이 아니라, 상태변경하여 UI업데이트
  Future<void> _onAddCategoryDialog() async{
  //void :  변환값 없음
  
    final ctrl = TextEditingController(); //입력 컨트롤러 생성
    final result = await showDialog<AddCategoryDialogResult>(
      context : context,
      builder: (_) => AddCategoryDialog(
        categories_flat : _categories_flat));

        if( result == null) return;
        
        try{
          final cat = await CategoryService.createCategory(
            result.name,
            parent_id : result.parent_id,
            icon_key: result.icon_key,
          );
          //서버에 카테고리 생성 요청 -> 성공 시 cat 반환한다. 
          //이 때 id, slug, name이 서버 기준으로 확정됨.
          if(!mounted) return; 
          //비동기 안전장치,
          //dialog띄운 상태에서 페이지가 dispose되었을 수 있으므로, 아직 살아 있을때만 UI업뎃.

          /*서버에 요청 성공, 그리고 아직 page가 살아 있다면 */
          //기존 원소에 추가되지 않았으면 추가해라. 
          setState(() {
            if(_categories_flat.indexWhere((c) => c.id ==cat.id) < 0 )
            //c : List인 categories_flat_의 원소 하나하나를 순회하며, 
            //(c) =>  c.id == cat.id  < 0 : 못찾으면 -1반환, 찾으면 0이상 return 했고, 그것이 0이하면, 아래 줄로
            {
              _categories_flat.add(cat);
              //추가해라. 
            }
            _selected_category_slug = cat.slug; //만든 카테고리 선택
            _error_msg = null;
            //만든 카테고리 녀석을 , 선택 상태로 가자. 
          });
          await _fetchCategories();
          //서버 기준으로 다시 동기화 
        } catch(e) {
          if(!mounted) return;
          setState(() => _error_msg = 'Create category error: $e');
        }
  }


  /* 썸네일로 쓸 이밎 파일 고름*/
  //고름 -> 바이트로 읽고 -> 서버에 얿로드 -> 업로드 된 URL을 상태에 저장해서 UI에 반영, 
  Future<void> _onPickThumbnail() async{
    try{
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png','jpg','jpeg', 'gif'],
        withData:true,
      );

      if(result == null) return; //사용자가 취소 시

      final file = result.files.single; 
      final Uint8List? bytes = file.bytes;
      //보통 이미지 데이터는 Uint8List로 전송한다.
    
      if(bytes ==null) {
        setState(() {
          _error_msg ="cannot read the thumbnail file! ㅜㅜ";
        });
        return;
      }

      final upload_result = await UploadService.uploadBytes(bytes: bytes, filename: file.name);
      if(!mounted) return;

      setState(() {
        _thumbnail_rel_url = upload_result.url;
        _thumbnail_full_url = upload_result.full_url;
        _error_msg = null;
      });

    } catch(e) {
      if(!mounted) return;
      setState(() {
        _error_msg = 'Thumbnail upload error: $e';
      });
    }
  }

  void _onRemoveThumbnail() {
    setState(() {
      _thumbnail_rel_url = null;
      _thumbnail_full_url = null;
    });
  }

  ///panel쪽에서 드롭다운박스쪽에서 값이변경되었을때 여기서 Post status 값을 알수 있고, 상태를 변경함.
  /// panel쪽에서 값 변경 감지하고, 부모위젯인 EditorPg에게 새 값 전달하여 부모가 자신의 상태(_status)를 갱신하고 리빌드 요청함.
  /// setState :  데이터가 바뀌었으니 다음 프레임에 build 다시 실행해서 UI를 갱신하라는 리빌드 요청
  void _onChangeStatus(PostStatus v) {
    setState(() => _status = v);
  }


  void _onSelectCategory(String slug){
    setState(() => _selected_category_slug = slug);
  } 

  Future<void> _insertMediaIntoMarkdown() async{
    try {
      final result = await FilePicker.platform.pickFiles(
        type : FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg', 'gif', 'mp4', 'mov'],
        withData: true,
      );
      if( result == null) return;
      final file = result.files.single;
      final Uint8List? bytes = file.bytes;
      if(bytes == null) {
        setState(() => _error_msg = '파일 데이터를 읽을 수 없습니다.');
        return;

      }
      /* 1) Nas로 업로드 */
      final upload_result = await UploadService.uploadBytes(bytes: bytes, filename: file.name);

      /* 2) image option dialogue*/
      final opt = await showDialog<ImageInsertOption>(
        //ImageInsertOption에서 다이얼로그가 완료 되면 opt로 그 결과값이 들어온다. 그래서 size, align, caption도 존재할것임.
        context: context,
        builder: (_) => const ImageOptionDialog(),
        //팝업이 뜬다. 
        //(_): 함수에서 굳이 인자를 쓰지 않아서 _씀. 
        // 원래는 context를 인자로 쓰는데, 내부에서 직접 자체 UI를 그리면 굳이 필ㅇ료 없음. 
        // 써야 할때는 홤녀 크기에 따라서 다르게 해야 할때,
       );
      if(opt == null) return;

      final alt= file.name.isNotEmpty ? file.name : 'media';
      final encoded_caption =  opt.caption == null 
      ? null
      : Uri.encodeComponent(opt.caption!);
      //ImageInsertOption에서 caption이라는 인자가존재.
      //캡션 문자열을 Uri에 안전하게 넣을수 있는 형태로 변환해서 넣음. 
      //예를 들어서, "my page" 면 인코딩 후 "my%20page"이런식으로 바뀜.

      //  final title_meta = 'size=${opt.size};align=${opt.align}';
      final title_meta = (encoded_caption != null&& encoded_caption.isNotEmpty)
            ? 'size=${opt.size};align=${opt.align};caption=$encoded_caption'
            : 'size=${opt.size};align=${opt.align}';
       //when I insert an image, I set the option correctly. but they are not applied when it is rendered.




       /* 3) insert markdown*/
        MarkdownInsert.insertImageMarkdown(
          controller: _body_ctrl, 
          full_url: upload_result.full_url,
          alt: alt,
          title_meta: title_meta
        );
        if(!mounted) return;
        setState(() => _error_msg =null);
    } catch (e) {
      if(!mounted) return; //UI 죽어 있으면 아무짓도 안하고 return, 여기서 어떤걸 return 시 crash됨.
      setState(() => _error_msg = 'Upload error : $e');

    }
  }

  /* */
  Future<void> _savePost() async{
    if(_is_saving) return;

    setState(() {
      _is_saving = true;
      _error_msg  =null;
    });

    try{
      if(widget.post_id ==null) {
        //New
        await PostService.createPost(
          title:_title_ctrl.text,
          body_markdown: _body_ctrl.text,
          tags: const ['note', 'study'],
          category_slug: _selected_category_slug,
          thumbnail_rel_url: _thumbnail_rel_url,
          status: _status // 서버에 추가해야 함. 

        );
      } else {
        //Edit
        await PostService.updatePost(
          id: widget.post_id!,
          title: _title_ctrl.text,
          body_markdown: _body_ctrl.text,
          tags: const ['note', 'study'],
          category_slug: _selected_category_slug,
          thumbnail_rel_url: _thumbnail_rel_url,
          status: _status,
          );
      }
        if(!mounted) return;
        Navigator.pop(context, true);

    } catch(e) {
      if(!mounted) return;
      setState(() => _error_msg = 'Save failed: $e');
    } finally {
      if(!mounted) return;
      setState(() => _is_saving = false);
    }
  }


  /*간단 preview */
  void _openPreview() {
    PreviewDialog.open(
      context,
      title: _title_ctrl.text,
      body: _body_ctrl.text,

    );
  }

  double _calcPadding(ScreenModel sm) {
    if(sm.web) return 16;
    if(sm.tablet) return 14;
    return 12;

  }

  double _calcGap(ScreenModel sm) {
    if(sm.web) return 16;
    if(sm.tablet) return 12;
    return 10;
  }

  Future<void> _loadExistingPost(String id) async{
    try{
      final post = await PostService.fetchPost(id); //PostDetail
      if(!mounted) return;

      setState(() {
        _title_ctrl.text = post.meta.title;
        _body_ctrl.text = post.body_markdown;
        _selected_category_slug = post.meta.category;

        /*썸네일 있으면 세팅 */
        final rel = post.meta.thumbnail; //필드명은 본인 meta에 맞게, 
        _thumbnail_rel_url = rel;
        _thumbnail_full_url = (rel == null || rel.isEmpty)
                              ? null
                              : (rel.startsWith('http') ? rel : '$NAS_BASE_URL$rel');
        _error_msg=null;
      });
    } catch (e) {
      if(!mounted) return;
      setState(() => _error_msg = 'Load post failed: $e');

    }

  }



}//end


