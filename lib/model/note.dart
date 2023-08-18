class Note {
  final int? id;
  final String title;
  final String desc;

  const Note({required this.title, required this.desc, required this.id});

  factory Note.fromJson(Map<String, dynamic> json) =>
      Note(id: json['id'], title: json['title'], desc: json['desc']);

  Map<String, dynamic> toJson() => {'id': id, 'title': title, 'desc': desc};
}
