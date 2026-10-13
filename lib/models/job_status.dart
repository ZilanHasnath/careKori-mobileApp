enum JobStatus {
  pending('pending', 'Pending'),
  active('Active', 'Active'),
  rejected('Rejected', 'Rejected'),
  finish('Finish', 'Finished');

  const JobStatus(this.wire, this.label);

  final String wire;
  final String label;

  static JobStatus parse(dynamic value) => JobStatus.values.firstWhere(
        (status) => status.wire == value?.toString(),
        orElse: () => JobStatus.pending,
      );
}
