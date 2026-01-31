
/*게시글 상태를 3가지 중 하나로 제한 -> 그 상태로 문자열로 변환 
  저장용 value : 기계/서버 친화적(소문자, 고정)
  표시용 label : 사람 친화적 (첫 글자 대문자)
*/
enum PostStatus{
  public,
  private,
  removed;

/*value getter 저장/ 통신용 문자열 */
  String get value{
    switch (this) {
    //여기 thiis는 PostStatus를 선언한 객체 ps.value를 뜻함. 
      case PostStatus.public:
        return 'public';
      case PostStatus.private:
        return 'private';
      case PostStatus.removed:
        return 'removed';
    }
  }
/* label getter UI 표시용 문자열 */
  String get label{
    switch(this) {
      case PostStatus.public:
        return 'public';
      case PostStatus.private:
        return 'private';
      case PostStatus.removed:
        return 'removed';
    }
  }
  
}
