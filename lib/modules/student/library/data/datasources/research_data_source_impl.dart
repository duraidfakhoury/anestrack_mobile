import 'package:logger/logger.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/modules/student/library/data/datasources/research_data_source.dart';
import 'package:anestrack_mobile/modules/student/library/data/models/research_paper_comment_model.dart';
import 'package:anestrack_mobile/modules/student/library/data/models/research_paper_model.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_comment_parameters.dart';
import 'package:anestrack_mobile/modules/student/library/domain/parameters/create_research_paper_parameters.dart';

class ResearchDataSourceImpl extends ResearchDataSource {
  final Logger _logger = Logger();

  dynamic _unwrap(dynamic data) {
    if (data is Map<String, dynamic> && data.containsKey('result')) {
      return data['result'];
    }
    return data;
  }

  @override
  Future<List<ResearchPaperModel>> listResearchPapers({
    int? limit,
    int? skip,
  }) async {
    try {
      _logger.i('Fetching research papers');
      final response = await NetworkHelper().get(
        ApisUrls().listResearchPapers,
        data: {
          if (limit != null) 'limit': limit,
          if (skip != null) 'skip': skip,
        },
      );
      final body = _unwrap(response.data);
      if (body is List) {
        return body
            .whereType<Map>()
            .map(
              (e) => ResearchPaperModel.fromJson(Map<String, dynamic>.from(e)),
            )
            .toList();
      }
      _logger.w('Unexpected research papers response: ${response.data}');
      return [];
    } catch (e) {
      _logger.e('Failed to fetch research papers: $e');
      rethrow;
    }
  }

  @override
  Future<ResearchPaperModel> getResearchPaper(String id) async {
    try {
      _logger.i('Fetching research paper $id');
      final response = await NetworkHelper().get(
        ApisUrls().getResearchPaper,
        data: {'id': id},
      );
      final body = _unwrap(response.data);
      if (body is Map) {
        return ResearchPaperModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception('Unexpected research paper response: ${response.data}');
    } catch (e) {
      _logger.e('Failed to fetch research paper $id: $e');
      rethrow;
    }
  }

  @override
  Future<ResearchPaperModel> createResearchPaper(
    CreateResearchPaperParameters parameters,
  ) async {
    try {
      _logger.i('Publishing research paper "${parameters.title}"');
      final response = await NetworkHelper().post(
        ApisUrls().createResearchPaper,
        data: parameters.toJson(),
      );
      final body = _unwrap(response.data);
      if (body is Map) {
        return ResearchPaperModel.fromJson(Map<String, dynamic>.from(body));
      }
      throw Exception('Unexpected create research paper response: ${response.data}');
    } catch (e) {
      _logger.e('Failed to publish research paper: $e');
      rethrow;
    }
  }

  @override
  Future<List<ResearchPaperCommentModel>> listResearchPaperComments(
    String paperId,
  ) async {
    try {
      _logger.i('Fetching comments for research paper $paperId');
      final response = await NetworkHelper().get(
        ApisUrls().listResearchPaperComments,
        data: {'paperId': paperId},
      );
      final body = _unwrap(response.data);
      if (body is List) {
        return body
            .whereType<Map>()
            .map(
              (e) => ResearchPaperCommentModel.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      }
      _logger.w('Unexpected research paper comments response format');
      return [];
    } catch (e) {
      _logger.e('Failed to fetch research paper comments: $e');
      rethrow;
    }
  }

  @override
  Future<ResearchPaperCommentModel> createResearchPaperComment(
    CreateResearchPaperCommentParameters parameters,
  ) async {
    try {
      // Not logging the raw response: the backend embeds the full author
      // _User object (including sessionToken) in this endpoint's response.
      _logger.i('Adding comment to research paper ${parameters.paperId}');
      final response = await NetworkHelper().post(
        ApisUrls().createResearchPaperComment,
        data: parameters.toJson(),
      );
      final body = _unwrap(response.data);
      if (body is Map) {
        final comment = ResearchPaperCommentModel.fromJson(
          Map<String, dynamic>.from(body),
        );
        _logger.i('Added comment ${comment.id}');
        return comment;
      }
      throw Exception('Unexpected create comment response format');
    } catch (e) {
      _logger.e('Failed to add research paper comment: $e');
      rethrow;
    }
  }
}
