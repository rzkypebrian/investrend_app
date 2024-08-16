// ignore_for_file: non_constant_identifier_names

import 'package:Investrend/utils/string_utils.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

enum PostType { POLL, TRANSACTION, PREDICTION, TEXT, Unknown }

extension PostTypeExtension on PostType {
  String get postName {
    switch (this) {
      case PostType.POLL:
        return 'POLL';
      case PostType.TRANSACTION:
        return 'TRANSACTION';
      case PostType.PREDICTION:
        return 'PREDICTION';
      case PostType.TEXT:
        return 'TEXT';
      default:
        return '#unknown_postName';
    }
  }
}

class Attachment extends KeysNeeded {
  final int id;
  final int post_id;
  final String attachment; // image file asli
  final int attachment_type;

  final String created_at;
  final String updated_at;
  final String attachment_list;
  final String attachment_small;
  final String attachment_index;
  final AttachmentInfo? attachment_info;

  Attachment(
      this.id,
      this.post_id,
      this.attachment,
      this.attachment_type,
      this.created_at,
      this.updated_at,
      this.attachment_list,
      this.attachment_small,
      this.attachment_index,
      this.attachment_info)
      : super();

  static Attachment? fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return Attachment(
        parsedJson['id'],
        parsedJson['post_id'],
        parsedJson['attachment'],
        parsedJson['attachment_type'],
        parsedJson['created_at'],
        parsedJson['updated_at'],
        parsedJson['attachment_list'],
        parsedJson['attachment_small'],
        parsedJson['attachment_index'],
        AttachmentInfo.fromJson(parsedJson['attachment_info']));
  }

  @override
  String toString() {
    return '[Attachment  id : $id  post_id : $post_id  attachment : $attachment  attachment_type : $attachment_type  created_at : $created_at  updated_at : $updated_at'
            '  attachment_list : $attachment_list  attachment_small : $attachment_small  attachment_index : $attachment_index  attachment_info : \n' +
        attachment_info.toString() +
        ']';
  }

  /*
  final int id;
  final int post_id;
  final String attachment; // image file asli
  final int attachment_type;

  final String created_at;
  final String updated_at;
  final String attachment_list;
  final String attachment_small;
  final String attachment_index;
  final AttachmentInfo attachment_info;
  */
  @override
  String membersIncludedInKey() {
    //String attachment_infoKeyString = attachment_info = null ? attachment_info.keyString : '';
    List<String?> members = [
      id.toString(),
      post_id.toString(),
      StringUtils.noNullString(attachment),
      attachment_type.toString(),
      StringUtils.noNullString(created_at),
      StringUtils.noNullString(updated_at),
      StringUtils.noNullString(attachment_list),
      StringUtils.noNullString(attachment_small),
      StringUtils.noNullString(attachment_index),
      (attachment_info != null ? attachment_info?.keyString : '')
    ];
    return members.join('_');
  }
}

class AttachmentInfo extends KeysNeeded {
  final String mime_type;
  final String url_path;
  final size;

  AttachmentInfo(this.mime_type, this.url_path, this.size) : super();

  static AttachmentInfo? fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return AttachmentInfo(
        parsedJson['mime_type'], parsedJson['url_path'], parsedJson['size']);
  }

  @override
  String toString() {
    return '[AttachmentInfo  mime_type : $mime_type  size : $size  url_path : $url_path]';
  }

  @override
  String membersIncludedInKey() {
    List<String?> members = [
      StringUtils.noNullString(mime_type),
      size.toString(),
      StringUtils.noNullString(url_path)
    ];
    return members.join('_');
  }
}

class UserSosMed extends KeysNeeded {
  final int active;
  final int attachment_type;
  final int featured_attachment_type;
  final int group_type;
  final int id;
  final int is_featured;
  final int log_in;

  final String attachment;
  final String attachment_info;
  final String created_at;
  final String current_log_in_at;
  final String current_log_in_ip;
  final String email;
  final String email_verified_at;
  final String featured_attachment;
  final String featured_attachment_index;
  final String featured_attachment_list;
  final String featured_attachment_small;
  final String featured_text;
  final String last_log_in_at;
  final String last_log_in_ip;
  final String name; // --
  final String thumbnail_url;
  final String updated_at;
  final String username; // --

  final String thumbnail;

  final AttachmentInfo? featured_attachment_info;

  @override
  String toString() {
    return '[UserSosMed  username : $username  name : $name  thumbnail : $thumbnail  thumbnail_url : $thumbnail_url  is_featured : $is_featured  featured_text : $featured_text  etc]';
  }

  UserSosMed(
      this.active,
      this.attachment_type,
      this.featured_attachment_type,
      this.group_type,
      this.id,
      this.is_featured,
      this.log_in,
      this.attachment,
      this.attachment_info,
      this.created_at,
      this.current_log_in_at,
      this.current_log_in_ip,
      this.email,
      this.email_verified_at,
      this.featured_attachment,
      this.featured_attachment_index,
      this.featured_attachment_list,
      this.featured_attachment_small,
      this.featured_text,
      this.last_log_in_at,
      this.last_log_in_ip,
      this.name,
      this.thumbnail_url,
      this.thumbnail,
      this.updated_at,
      this.username,
      this.featured_attachment_info)
      : super(); // DATA

  static UserSosMed? fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    return UserSosMed(
      parsedJson['this.active'],
      parsedJson['attachment_type'],
      parsedJson['featured_attachment_type'],
      parsedJson['group_type'],
      parsedJson['id'],
      parsedJson['is_featured'],
      parsedJson['log_in'],
      parsedJson['attachment'],
      parsedJson['attachment_info'],
      parsedJson['created_at'],
      parsedJson['current_log_in_at'],
      parsedJson['current_log_in_ip'],
      parsedJson['email'],
      parsedJson['email_verified_at'],
      parsedJson['featured_attachment'],
      parsedJson['featured_attachment_index'],
      parsedJson['featured_attachment_list'],
      parsedJson['featured_attachment_small'],
      parsedJson['featured_text'],
      parsedJson['last_log_in_at'],
      parsedJson['last_log_in_ip'],
      parsedJson['name'],
      parsedJson['thumbnail_url'],
      parsedJson['thumbnail'],
      parsedJson['updated_at'],
      parsedJson['username'],
      AttachmentInfo.fromJson(parsedJson['featured_attachment_info']),
    );
  }

  @override
  String membersIncludedInKey() {
    List<String?> members = [
      active.toString(),
      attachment_type.toString(),
      featured_attachment_type.toString(),

      group_type.toString(),
      id.toString(),
      is_featured.toString(),
      log_in.toString(),

      StringUtils.noNullString(attachment),
      StringUtils.noNullString(attachment_info),
      StringUtils.noNullString(created_at),
      StringUtils.noNullString(current_log_in_at),
      StringUtils.noNullString(current_log_in_ip),
      StringUtils.noNullString(email),
      StringUtils.noNullString(email_verified_at),
      StringUtils.noNullString(featured_attachment),
      StringUtils.noNullString(featured_attachment_index),
      StringUtils.noNullString(featured_attachment_list),
      StringUtils.noNullString(featured_attachment_small),
      StringUtils.noNullString(featured_text),
      StringUtils.noNullString(last_log_in_at),
      StringUtils.noNullString(last_log_in_ip),
      StringUtils.noNullString(name), // --
      StringUtils.noNullString(thumbnail_url),
      StringUtils.noNullString(thumbnail),
      StringUtils.noNullString(updated_at),
      StringUtils.noNullString(username),
      (featured_attachment_info != null
          ? featured_attachment_info?.keyString
          : '')
    ];
    return members.join('_');
  }
}

class Poll extends KeysNeeded {
  int count;
  final String created_at;
  final int id;
  final int post_id;
  final String text;
  final String updated_at;
  bool voted;

  Poll(this.count, this.created_at, this.id, this.post_id, this.text,
      this.updated_at, this.voted)
      : super();

  factory Poll.fromJson(Map<String, dynamic> parsedJson) {
    return Poll(
        parsedJson['count'],
        parsedJson['created_at'],
        parsedJson['id'],
        parsedJson['post_id'],
        parsedJson['text'],
        parsedJson['updated_at'],
        parsedJson['voted']);
  }

  @override
  String toString() {
    return '[Polls  count : $count  created_at : $created_at  id : $id  post_id : $post_id  text : $text  updated_at : $updated_at  voted : $voted  keyString : $keyString]';
  }

  void voteSuccess() {
    voted = true;
    count++;
    print('Poll OLD voteSuccess keyString : $keyString');
    generateKeyString();
    print('Poll NEW voteSuccess  keyString : $keyString');
  }

  @override
  String membersIncludedInKey() {
    List<String?> members = [
      count.toString(),
      StringUtils.noNullString(created_at),
      id.toString(),
      post_id.toString(),
      StringUtils.noNullString(text),
      StringUtils.noNullString(updated_at),
      voted.toString(),
    ];
    return members.join('_');
  }
}

abstract class KeysNeeded {
  String? _keyString;

  lateKeysNeeded() {
    generateKeyString();
  }

  String membersIncludedInKey();

  String? generateKeyString() {
    String raw = StringUtils.isEmtpy(membersIncludedInKey())
        ? DateTime.now().toString()
        : membersIncludedInKey();
    _keyString = generateMd5(raw);
    print('generateKeyString : $_keyString');
    return keyString;
  }

  String? get keyString => _keyString;

  String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }
}

class Post extends KeysNeeded {
  final int? id;
  final String? slug;
  final int? user_id;
  final String? type;
  final String? text;
  final String? tag;
  final int? is_featured;
  final int? is_trending;
  final String? code;
  final int? target_price;
  final String? transaction_type;
  final String? expired_at;
  final String? attachment;
  final int? attachment_type;
  final String? attachment_info;
  int? voter_count;
  int? like_count;
  final int? comment_count;
  final String? created_at;
  final String? updated_at;
  final String? deleted_at;
  final String? stock_name;
  final int? start_price;
  final int? sell_price;
  bool? liked;
  bool? voted;
  final List<Poll>? polls;
  final List<PostComment>? top_comments;
  final UserSosMed? user;
  final List<Attachment?>? attachments;

  final PostType? postType;

  int? pollsCount() {
    return polls != null ? polls?.length : 0;
  }

  int? attachmentsCount() {
    return attachments != null ? attachments?.length : 0;
  }

  @override
  String toString() {
    return '[Post  user_id : $user_id  type : $type  text : $text  code : $code  target_price : $target_price  voter_count : $voter_count  like_count : $like_count  comment_count : $comment_count  like_count : $like_count  comment_count : $comment_count  expired_at : $expired_at]';
  }

  static Post createSimple() {
    return Post(
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null);
  }

  Post(
      this.postType,
      this.user,
      this.id,
      this.slug,
      this.user_id,
      this.type,
      this.text,
      this.tag,
      this.is_featured,
      this.is_trending,
      this.code,
      this.target_price,
      this.transaction_type,
      this.expired_at,
      this.attachment,
      this.attachment_type,
      this.attachment_info,
      this.voter_count,
      this.like_count,
      this.comment_count,
      this.created_at,
      this.updated_at,
      this.deleted_at,
      this.stock_name,
      this.start_price,
      this.sell_price,
      this.liked,
      this.voted,
      this.polls,
      this.top_comments,
      this.attachments)
      : super();

  factory Post.fromJson(Map<String, dynamic> parsedJson) {
    List<dynamic>? listAttachments = parsedJson['attachments'] as List?;
    print(listAttachments.runtimeType); //returns List<dynamic>
    List<Attachment?>? attachments;
    if (listAttachments != null) {
      attachments = listAttachments.map((i) => Attachment.fromJson(i)).toList();
    }

    List<dynamic>? listPolls = parsedJson['polls'] as List?;
    print(listPolls.runtimeType); //returns List<dynamic>
    List<Poll>? polls;
    if (listPolls != null) {
      polls = listPolls.map((i) => Poll.fromJson(i)).toList();
    }

    // belum tau structure data cooment kek gimana? tanya TKB

    var listTopComments = parsedJson['top_comments'] as List?;
    print(listTopComments.runtimeType);
    List<PostComment>? topComments;
    if (listTopComments != null) {
      topComments =
          listTopComments.map((i) => PostComment.fromJson(i)).toList();
    }

    String type = parsedJson['type'];
    PostType postType;
    if (StringUtils.equalsIgnoreCase(type, 'POLL')) {
      postType = PostType.POLL;
    } else if (StringUtils.equalsIgnoreCase(type, 'TRANSACTION')) {
      postType = PostType.TRANSACTION;
    } else if (StringUtils.equalsIgnoreCase(type, 'PREDICTION')) {
      postType = PostType.PREDICTION;
    } else if (StringUtils.equalsIgnoreCase(type, 'TEXT')) {
      postType = PostType.TEXT;
    } else {
      postType = PostType.Unknown;
    }

    //return Post(parsedJson['accountcode'], parsedJson['accountname'], parsedJson['branchcode'], parsedJson['brokercode'], parsedJson['type']);

    return Post(
        postType,
        UserSosMed.fromJson(parsedJson['user']),
        parsedJson['id'],
        parsedJson['slug'],
        parsedJson['user_id'],
        type,
        //parsedJson['type'],
        parsedJson['text'],
        parsedJson['tag'],
        parsedJson['is_featured'],
        parsedJson['is_trending'],
        parsedJson['code'],
        parsedJson['target_price'],
        parsedJson['transaction_type'],
        parsedJson['expired_at'],
        parsedJson['attachment'],
        parsedJson['attachment_type'],
        parsedJson['attachment_info'],
        parsedJson['voter_count'],
        parsedJson['like_count'],
        parsedJson['comment_count'],
        parsedJson['created_at'],
        parsedJson['updated_at'],
        parsedJson['deleted_at'],
        parsedJson['stock_name'],
        parsedJson['start_price'],
        parsedJson['sell_price'],
        parsedJson['liked'],
        parsedJson['voted'],
        polls,
        topComments,
        attachments);
  }

  void likedSuccess() {
    liked = true;
    if (like_count != null) {
      like_count = like_count! + 1;
    }
    print('Post OLD likedSuccess keyString : $keyString');
    generateKeyString();
    print('Post NEW likedSuccess keyString : $keyString');
  }

  void likedUndoed() {
    liked = false;
    if (like_count != null) {
      like_count = like_count! - 1;
    }
    print('Post OLD likedUndoed keyString : $keyString');
    generateKeyString();
    print('Post NEW likedUndoed keyString : $keyString');
  }

  void voteSuccess() {
    voted = true;
    if (voter_count != null) {
      voter_count = like_count! + 1;
    }
    print('Post OLD voteSuccess keyString : $keyString');
    generateKeyString();
    print('Post NEW voteSuccess keyString : $keyString');
  }

  @override
  String membersIncludedInKey() {
    String? pollsString;
    if (polls == null || polls!.isEmpty) {
      pollsString = '';
    } else {
      polls?.forEach((poll) {
        if (StringUtils.isEmtpy(pollsString)) {
          pollsString = poll.keyString;
        } else {
          if (pollsString != null) {
            pollsString = pollsString! + '|' + poll.keyString!;
          }
          // pollsString += '|' + poll.keyString;
        }
      });
    }
    String? topCommentsString;
    if (top_comments == null || top_comments!.isEmpty) {
      topCommentsString = '';
    } else {
      top_comments?.forEach((comment) {
        if (StringUtils.isEmtpy(topCommentsString)) {
          topCommentsString = comment.keyString;
        } else {
          if (topCommentsString != null) {
            topCommentsString = topCommentsString! + '|' + comment.keyString!;
          }
          // topCommentsString += '|' + comment.keyString;
        }
      });
    }

    List<String?> members = [
      id.toString(),
      StringUtils.noNullString(slug),
      user_id.toString(),
      type.toString(),
      StringUtils.noNullString(text)?.length.toString(),
      StringUtils.noNullString(tag),
      is_featured.toString(),
      is_trending.toString(),
      StringUtils.noNullString(code),
      target_price.toString(),
      StringUtils.noNullString(transaction_type),
      StringUtils.noNullString(expired_at),
      StringUtils.noNullString(attachment),
      attachment_type.toString(),
      StringUtils.noNullString(attachment_info),
      voter_count.toString(),
      like_count.toString(),
      comment_count.toString(),
      StringUtils.noNullString(created_at),
      StringUtils.noNullString(updated_at),
      StringUtils.noNullString(deleted_at),
      StringUtils.noNullString(stock_name),
      start_price.toString(),
      sell_price.toString(),
      liked.toString(),
      voted.toString(),
      pollsString,
      topCommentsString,
      (user != null ? user?.keyString : ''),
    ];
    return members.join('_');
  }
}

class ResultPost {
  final int current_page;

  //final String data; // array
  final String first_page_url;
  final int from;
  final int last_page;
  final String last_page_url;

  //final String links; // array
  final String next_page_url;
  final String path;
  final int per_page;
  final String prev_page_url;
  final int to;
  final int total;
  final List<Post>? posts;

  ResultPost(
      this.current_page,
      this.first_page_url,
      this.from,
      this.last_page,
      this.last_page_url,
      this.next_page_url,
      this.path,
      this.per_page,
      this.prev_page_url,
      this.to,
      this.total,
      this.posts);

  static ResultPost? fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    var listPost = parsedJson['data'] as List;
    print(listPost.runtimeType); //returns List<dynamic>
    List<Post> posts = listPost.map((i) => Post.fromJson(i)).toList();

    return ResultPost(
        parsedJson['current_page'],
        parsedJson['first_page_url'],
        parsedJson['from'],
        parsedJson['last_page'],
        parsedJson['last_page_url'],
        parsedJson['next_page_url'],
        parsedJson['path'],
        parsedJson['per_page'],
        parsedJson['prev_page_url'],
        parsedJson['to'],
        parsedJson['total'],
        posts);
  }

  int? countPost() {
    return posts != null ? posts?.length : 0;
  }

  @override
  String toString() {
    return 'ResultPost current_page : $current_page first_page_url : $first_page_url '
            'from : $from last_page : $last_page last_page_url : $last_page_url'
            'next_page_url : $next_page_url path : $path per_page : $per_page'
            'prev_page_url : $prev_page_url to : $to total : $total posts : ' +
        countPost().toString();
  }
}

class ResultComment {
  final int current_page;

  //final String data; // array
  final String first_page_url;
  final int from;
  final int last_page;
  final String last_page_url;

  //final String links; // array
  final String next_page_url;
  final String path;
  final int per_page;
  final String prev_page_url;
  final int to;
  final int total;
  final List<PostComment>? comments;

  ResultComment(
      this.current_page,
      this.first_page_url,
      this.from,
      this.last_page,
      this.last_page_url,
      this.next_page_url,
      this.path,
      this.per_page,
      this.prev_page_url,
      this.to,
      this.total,
      this.comments);

  static ResultComment? fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null) {
      return null;
    }

    var listComments = parsedJson['data'] as List;
    print(listComments.runtimeType); //returns List<dynamic>
    List<PostComment> comments =
        listComments.map((i) => PostComment.fromJson(i)).toList();

    return ResultComment(
        parsedJson['current_page'],
        parsedJson['first_page_url'],
        parsedJson['from'],
        parsedJson['last_page'],
        parsedJson['last_page_url'],
        parsedJson['next_page_url'],
        parsedJson['path'],
        parsedJson['per_page'],
        parsedJson['prev_page_url'],
        parsedJson['to'],
        parsedJson['total'],
        comments);
  }

  int? countComments() {
    return comments != null ? comments?.length : 0;
  }

  @override
  String toString() {
    return 'ResultComment current_page : $current_page first_page_url : $first_page_url '
            'from : $from last_page : $last_page last_page_url : $last_page_url'
            'next_page_url : $next_page_url path : $path per_page : $per_page'
            'prev_page_url : $prev_page_url to : $to total : $total comments : ' +
        countComments().toString();
  }
}

class FetchPost {
  int status;
  String message;
  ResultPost? result;

  FetchPost(this.status, this.message, this.result);

  factory FetchPost.fromJson(Map<String, dynamic> parsedJson) {
    // var list = parsedJson['accounts'] as List;
    // print(list.runtimeType); //returns List<dynamic>
    // List<Account> accountList = list.map((i) => Account.fromJson(i)).toList();

    return FetchPost(
      parsedJson['status'],
      parsedJson['message'],
      ResultPost.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'FetchPost status : $status message : $message result : \n' +
        result.toString();
  }
}

class FetchComment {
  int status;
  String message;
  ResultComment? result;

  FetchComment(this.status, this.message, this.result);

  factory FetchComment.fromJson(Map<String, dynamic> parsedJson) {
    // var list = parsedJson['accounts'] as List;
    // print(list.runtimeType); //returns List<dynamic>
    // List<Account> accountList = list.map((i) => Account.fromJson(i)).toList();

    return FetchComment(
      parsedJson['status'],
      parsedJson['message'],
      ResultComment.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'FetchComment status : $status message : $message result : \n' +
        result.toString();
  }
}

class SubmitBasic {
  int status;
  String message;

  SubmitBasic(this.status, this.message);

  factory SubmitBasic.fromJson(Map<String, dynamic> parsedJson) {
    int status = parsedJson['status'];
    print(status);
    String message = parsedJson['message'];
    print(message);
    return SubmitBasic(status, message);
  }

  @override
  String toString() {
    return 'SubmitBasic status : $status message : $message ';
  }
}

class SubmitLike {
  int status;
  String message;
  ResultLike? result;

  SubmitLike(this.status, this.message, this.result);

  factory SubmitLike.fromJson(Map<String, dynamic> parsedJson) {
    // var list = parsedJson['accounts'] as List;
    // print(list.runtimeType); //returns List<dynamic>
    // List<Account> accountList = list.map((i) => Account.fromJson(i)).toList();

    int status = parsedJson['status'];
    print(status);
    String message = parsedJson['message'];
    print(message);
    return SubmitLike(
      //parsedJson['status'],
      //parsedJson['message'],
      status,
      message,
      ResultLike.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'SubmitLike status : $status message : $message result : \n' +
        result.toString();
  }
}

class SubmitVote {
  int status;
  String message;
  ResultVote? result;

  SubmitVote(this.status, this.message, this.result);

  factory SubmitVote.fromJson(Map<String, dynamic> parsedJson) {
    /*
    {
      "status": 200,
      "message": "Poll created",
      "result": {
        "user_id": 1,
        "post_poll_id": "1",
        "updated_at": "2021-07-27T15:35:36.000000Z",
        "created_at": "2021-07-27T15:35:36.000000Z",
        "id": 8
      }
    }
    */
    int status = parsedJson['status'];
    print(status);
    String message = parsedJson['message'];
    print(message);
    return SubmitVote(
      //parsedJson['status'],
      //parsedJson['message'],
      status,
      message,
      ResultVote.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'SubmitVote status : $status message : $message result : \n' +
        result.toString();
  }
}

class SubmitCreateComment {
  int status;
  String message;
  ResultCreateComment? result;

  SubmitCreateComment(this.status, this.message, this.result);

  factory SubmitCreateComment.fromJson(Map<String, dynamic> parsedJson) {
    /*
    {
      "status": 200,
      "message": "Poll created",
      "result": {
        "user_id": 1,
        "post_poll_id": "1",
        "updated_at": "2021-07-27T15:35:36.000000Z",
        "created_at": "2021-07-27T15:35:36.000000Z",
        "id": 8
      }
    }
    */
    int status = parsedJson['status'];
    print(status);
    String message = parsedJson['message'];
    print(message);
    return SubmitCreateComment(
      //parsedJson['status'],
      //parsedJson['message'],
      status,
      message,
      ResultCreateComment.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'SubmitVote status : $status message : $message result : \n' +
        result.toString();
  }
}

class SubmitCreateText {
  int status;
  String message;
  ResultCreatePostText? result;

  SubmitCreateText(this.status, this.message, this.result);

  factory SubmitCreateText.fromJson(Map<String, dynamic> parsedJson) {
    /*
    {
      "status": 200,
      "message": "Post created",
      "result": {
          "slug": "TEXT-1627456304-2060",
          "user_id": 1,
          "type": "TEXT",
          "text": "Halo semua",
          "updated_at": "2021-07-28T07:11:44.000000Z",
          "created_at": "2021-07-28T07:11:44.000000Z",
          "id": 36,
          "polls": [],
          "top_comments": [],
          "liked": false,
          "voted": false
      }
    }
    */
    int status = parsedJson['status'];
    print(status);
    String message = parsedJson['message'];
    print(message);
    return SubmitCreateText(
      //parsedJson['status'],
      //parsedJson['message'],
      status,
      message,
      ResultCreatePostText.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'SubmitCreateText status : $status message : $message result : \n' +
        result.toString();
  }
}

class SubmitCreateTransaction {
  int status;
  String message;
  ResultCreatePostTransaction? result;

  SubmitCreateTransaction(this.status, this.message, this.result);

  factory SubmitCreateTransaction.fromJson(Map<String, dynamic> parsedJson) {
    /*
    {
      "status": 200,
      "message": "Post created",
      "result": {
          "slug": "TEXT-1627456304-2060",
          "user_id": 1,
          "type": "TEXT",
          "text": "Halo semua",
          "updated_at": "2021-07-28T07:11:44.000000Z",
          "created_at": "2021-07-28T07:11:44.000000Z",
          "id": 36,
          "polls": [],
          "top_comments": [],
          "liked": false,
          "voted": false
      }
    }
    */
    int status = parsedJson['status'];
    print(status);
    String message = parsedJson['message'];
    print(message);
    return SubmitCreateTransaction(
      //parsedJson['status'],
      //parsedJson['message'],
      status,
      message,
      ResultCreatePostTransaction.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'SubmitCreateText status : $status message : $message result : \n' +
        result.toString();
  }
}

class SubmitCreatePolls {
  int status;
  String message;

  //ResultCreatePostText result;

  SubmitCreatePolls(this.status, this.message /*, this.result*/);

  factory SubmitCreatePolls.fromJson(Map<String, dynamic> parsedJson) {
    /*
    {
      "status": 200,
      "message": "200_post_created",
      "result": {
          "slug": "POLL-1627488135-805",
          "user_id": 1,
          "type": "POLL",
          "text": "Pada dapat BBCA gk?",
          "updated_at": "2021-07-28T16:02:15.000000Z",
          "created_at": "2021-07-28T16:02:15.000000Z",
          "id": 15,
          "polls": [
              {
                  "id": 7,
                  "post_id": 15,
                  "text": "YA",
                  "count": 0,
                  "created_at": "2021-07-28T16:02:15.000000Z",
                  "updated_at": "2021-07-28T16:02:15.000000Z"
              },
              {
                  "id": 8,
                  "post_id": 15,
                  "text": "TIDAK",
                  "count": 0,
                  "created_at": "2021-07-28T16:02:15.000000Z",
                  "updated_at": "2021-07-28T16:02:15.000000Z"
              }
          ],
          "top_comments": []
      }
    }
    */
    int status = parsedJson['status'];
    print(status);
    String message = parsedJson['message'];
    print(message);
    return SubmitCreatePolls(
      status,
      message,
      //ResultCreatePostText.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'SubmitCreatePolls status : $status message : $message';
  }
}

class SubmitCreatePrediction {
  int status;
  String message;

  //ResultCreatePostText result;

  SubmitCreatePrediction(this.status, this.message /*, this.result*/);

  factory SubmitCreatePrediction.fromJson(Map<String, dynamic> parsedJson) {
    /*
    {
      "status": 200,
      "message": "200_post_created",
      "result": {
          "slug": "POLL-1627488135-805",
          "user_id": 1,
          "type": "POLL",
          "text": "Pada dapat BBCA gk?",
          "updated_at": "2021-07-28T16:02:15.000000Z",
          "created_at": "2021-07-28T16:02:15.000000Z",
          "id": 15,
          "polls": [
              {
                  "id": 7,
                  "post_id": 15,
                  "text": "YA",
                  "count": 0,
                  "created_at": "2021-07-28T16:02:15.000000Z",
                  "updated_at": "2021-07-28T16:02:15.000000Z"
              },
              {
                  "id": 8,
                  "post_id": 15,
                  "text": "TIDAK",
                  "count": 0,
                  "created_at": "2021-07-28T16:02:15.000000Z",
                  "updated_at": "2021-07-28T16:02:15.000000Z"
              }
          ],
          "top_comments": []
      }
    }
    */
    int status = parsedJson['status'];
    print(status);
    String message = parsedJson['message'];
    print(message);
    return SubmitCreatePrediction(
      status,
      message,
      //ResultCreatePostText.fromJson(parsedJson['result']),
    );
  }

  @override
  String toString() {
    return 'SubmitCreatePrediction status : $status message : $message';
  }
}

class ResultLike {
  //int id;
  //String created_at;
  String post_id;

  //String updated_at;
  int user_id;

  //{"status":200,"message":"Like created","result":{"user_id":1,"post_id":"31"}}
  //ResultLike(this.id, this.post_id, this.user_id, this.created_at, this.updated_at);
  ResultLike(this.post_id, this.user_id);

  static ResultLike? fromJson(Map<String, dynamic>? parsedJson) {
    if (parsedJson == null) {
      return null;
    }
    // int id = parsedJson['id'];
    // print(id);
    // String created_at = parsedJson['created_at'];
    // print(created_at);
    String postId = parsedJson['post_id'].toString();
    print(postId);
    // String updated_at = parsedJson['updated_at'];
    // print(updated_at);
    int userId = parsedJson['user_id'];
    print(userId);

    //return ResultLike(id, post_id, user_id, created_at, updated_at);
    return ResultLike(postId, userId);
  }

  @override
  String toString() {
    //return 'ResultLike id : $id  post_id : $post_id  user_id : $user_id  created_at : $created_at  updated_at : $updated_at';
    return 'ResultLike post_id : $post_id  user_id : $user_id';
  }
}

class ResultVote {
  int id;
  String created_at;
  String post_poll_id;
  String updated_at;
  int user_id;

  ResultVote(this.id, this.post_poll_id, this.user_id, this.created_at,
      this.updated_at);

  static ResultVote? fromJson(Map<String, dynamic>? parsedJson) {
    /*
    {
      "status": 200,
      "message": "Poll created",
      "result": {
        "user_id": 1, --
        "post_poll_id": "1",
        "updated_at": "2021-07-27T15:35:36.000000Z", --
        "created_at": "2021-07-27T15:35:36.000000Z", --
        "id": 8 --
      }
    }
    */
    if (parsedJson == null) {
      return null;
    }
    int id = parsedJson['id'];
    print(id);
    String createdAt = parsedJson['created_at'];
    print(createdAt);
    String postPollId = parsedJson['post_poll_id'].toString();
    print(postPollId);
    String updatedAt = parsedJson['updated_at'];
    print(updatedAt);
    int userId = parsedJson['user_id'];
    print(userId);

    return ResultVote(id, postPollId, userId, createdAt, updatedAt);
  }

  @override
  String toString() {
    return 'ResultVote id : $id  post_poll_id : $post_poll_id  user_id : $user_id  created_at : $created_at  updated_at : $updated_at';
  }
}

class ResultCreateComment {
  int user_id;
  String post_id;
  String text;
  String updated_at;
  String created_at;
  int id;
  //"top_replies": []

  ResultCreateComment(this.user_id, this.post_id, this.text, this.updated_at,
      this.created_at, this.id);

  static ResultCreateComment? fromJson(Map<String, dynamic>? parsedJson) {
    /*
    {
        "status": 200,
        "message": "Comment created",
        "result": {
            "user_id": 1,
            "post_id": "1",
            "text": "Salam kenal",
            "updated_at": "2021-07-31T02:16:47.000000Z",
            "created_at": "2021-07-31T02:16:47.000000Z",
            "id": 20,
            "top_replies": []
        }
    }
    */
    if (parsedJson == null) {
      return null;
    }

    return ResultCreateComment(
        parsedJson['user_id'],
        parsedJson['post_id'].toString(),
        parsedJson['text'],
        parsedJson['updated_at'],
        parsedJson['created_at'],
        parsedJson['id']);
  }

  @override
  String toString() {
    return 'ResultCreateComment user_id : $user_id  post_id : $post_id  text : $text  updated_at : $updated_at  created_at : $id  created_at : $id';
  }
}

class ResultCreatePostText {
  final String slug;
  final int user_id;
  final String type;
  final String text;
  final String updated_at;
  final String created_at;
  final int id;
  final bool liked;
  final bool voted;

  //final String polls; // array
  //final String top_comments; // array

  ResultCreatePostText(this.slug, this.user_id, this.type, this.text,
      this.updated_at, this.created_at, this.id, this.liked, this.voted);

  static ResultCreatePostText? fromJson(Map<String, dynamic>? parsedJson) {
    /*
    {
      "status": 200,
      "message": "Post created",
      "result": {
          "slug": "TEXT-1627456304-2060",
          "user_id": 1,
          "type": "TEXT",
          "text": "Halo semua",
          "updated_at": "2021-07-28T07:11:44.000000Z",
          "created_at": "2021-07-28T07:11:44.000000Z",
          "id": 36,
          "polls": [],
          "top_comments": [],
          "liked": false,
          "voted": false
      }
    }
    */
    if (parsedJson == null) {
      return null;
    }
    return ResultCreatePostText(
        parsedJson['slug'],
        parsedJson['user_id'],
        parsedJson['type'],
        parsedJson['text'],
        parsedJson['updated_at'],
        parsedJson['created_at'],
        parsedJson['id'],
        parsedJson['liked'],
        parsedJson['voted']);
  }

  @override
  String toString() {
    return 'ResultCreatePostText slug : $slug  user_id : $user_id  type : $type  text : $text  updated_at : $updated_at'
        '  created_at : $created_at  id : $id  liked : $liked  voted : $voted';
  }
}

class ResultCreatePostTransaction {
  final String slug;
  final int user_id;
  final String type;
  final String text;
  final String code;
  final String start_price;
  final String transaction_type;
  final String sell_price;
  final String updated_at;
  final String created_at;
  final int id;
  final bool liked;
  final bool voted;

  ResultCreatePostTransaction(
      this.slug,
      this.user_id,
      this.type,
      this.text,
      this.code,
      this.start_price,
      this.transaction_type,
      this.sell_price,
      this.updated_at,
      this.created_at,
      this.id,
      this.liked,
      this.voted);

  static ResultCreatePostTransaction? fromJson(
      Map<String, dynamic>? parsedJson) {
    /*
    "result": {
        "slug": "TRANSACTION-1627543115-3919",
        "user_id": 1,
        "type": "TRANSACTION",
        "text": "Coba beli",
        "code": "BBCA",
        "start_price": "32500",
        "transaction_type": "BUY",
        "sell_price": 0,
        "updated_at": "2021-07-29T07:18:35.000000Z",
        "created_at": "2021-07-29T07:18:35.000000Z",
        "id": 55,
        "polls": [],
        "top_comments": [],
        "liked": false,
        "voted": false
    }
    */
    if (parsedJson == null) {
      return null;
    }

    return ResultCreatePostTransaction(
        parsedJson['slug'],
        parsedJson['user_id'],
        parsedJson['type'],
        parsedJson['text'],
        parsedJson['code'],
        parsedJson['start_price'].toString(),
        parsedJson['transaction_type'],
        parsedJson['sell_price'].toString(),
        parsedJson['updated_at'],
        parsedJson['created_at'],
        parsedJson['id'],
        parsedJson['liked'],
        parsedJson['voted']);
  }

  @override
  String toString() {
    return 'ResultCreatePostTransaction  slug : $slug  user_id : $user_id  type : $type  text : $text  code : $code  start_price : $start_price  transaction_type : $transaction_type  sell_price : $sell_price  updated_at : $updated_at  created_at : $created_at  id : $id  liked : $liked  voted : $voted ';
  }
}

class Vote {
  String code = '';
  int count = 0;

  Vote(this.code, this.count);
}

class Votes {
  String expires = '';
  int totalVotes = 0;
  List<Vote> _list = List.empty(growable: true);

  Votes(this.expires, this.totalVotes);

  void addVote(Vote vote) {
    _list.add(vote);
  }

  Vote getVote(int index) {
    return _list.elementAt(index);
  }

  int voteMemberCount() {
    return _list.length;
  }
}

class Prediction {
  String code = '';
  String name = '';
  int targetPrice = 0;
  int startPrice = 0;
  double upsidePercentage = 0.0;
  String timing = '';
  int countAgree = 0;
  int countDisagree = 0;
  int totalVotes = 0;
  String expires = '';

  Prediction(
      this.code,
      this.name,
      this.targetPrice,
      this.startPrice,
      this.upsidePercentage,
      this.timing,
      this.countAgree,
      this.countDisagree,
      this.totalVotes,
      this.expires);
}

class CommentOld {
  final String avatarUrl;
  final String name;
  final String username;
  final String label;
  final String datetime;
  final String text;

  CommentOld(this.avatarUrl, this.name, this.username, this.label,
      this.datetime, this.text);
}

class PostComment extends KeysNeeded {
  final String created_at; // --
  final String deleted_at; // --
  final int id; // --
  final int post_comment_id;
  final int post_id; // --
  final int reply_count; // --
  final String text; // --

  //final String top_replies; // array
  final String updated_at; // --

  final int user_id; // --
  final UserSosMed? user; // --

  PostComment(
      this.created_at,
      this.deleted_at,
      this.id,
      this.post_comment_id,
      this.post_id,
      this.reply_count,
      this.text,
      this.updated_at,
      this.user_id,
      this.user)
      : super();

  factory PostComment.fromJson(Map<String, dynamic> parsedJson) {
    return PostComment(
        parsedJson['created_at'],
        parsedJson['deleted_at'],
        parsedJson['id'],
        parsedJson['post_comment_id'],
        parsedJson['post_id'],
        parsedJson['reply_count'],
        parsedJson['text'],
        parsedJson['updated_at'],
        parsedJson['user_id'],
        UserSosMed.fromJson(parsedJson['user']));
  }

  @override
  String membersIncludedInKey() {
    List<String?> members = [
      StringUtils.noNullString(created_at),
      StringUtils.noNullString(deleted_at),
      id.toString(),
      post_comment_id.toString(),
      post_id.toString(),
      reply_count.toString(),
      StringUtils.noNullString(text)?.length.toString(),
      StringUtils.noNullString(updated_at),
      user_id.toString(),
    ];
    return members.join('_');
  }
}
