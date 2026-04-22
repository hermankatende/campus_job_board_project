import 'package:cjb/data/post_entity.dart';
import 'package:cjb/services/jobs_service.dart';

class PostService {
  final JobsService _jobsService = JobsService.instance;
  List<PostEntity> _cachedPosts = [];

  Future<List<PostEntity>> fetchPosts() async {
    if (_cachedPosts.isNotEmpty) {
      return _cachedPosts; // Return cached posts
    }

    try {
      final jobs = await _jobsService.fetchJobs();
      _cachedPosts = jobs
          .map(
            (job) => PostEntity(
              jobId: job.id,
              jobTitle: job.title,
              location: job.location,
              employmentType: job.employmentType,
              requirements: job.requirements,
              username: job.postedByName.isNotEmpty ? job.postedByName : 'User',
              description: job.description,
              imageUrl: job.imageUrl,
              email: job.company,
              timestamp: job.createdAt,
            ),
          )
          .toList();
      return _cachedPosts;
    } catch (e) {
      throw Exception('Failed to fetch feed posts: $e');
    }
  }
}
