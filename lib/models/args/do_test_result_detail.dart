
class DoTestResultDetailArg {
  final int attemptId;
  final String courseName;
  final int cmid;
  final int quizId;
  final int courseId;
  final int? initialPage; // To jump to a specific question if needed

  DoTestResultDetailArg({
    required this.attemptId,
    required this.courseName,
    required this.cmid,
    required this.quizId,
    required this.courseId,
    this.initialPage,
  });
}
