class AudioModel {
  String? name;
  String? author;
  String? albumtitle;
  String? albumlink;

  AudioModel(this.name, this.author, this.albumtitle, this.albumlink);

  @override
  String toString() {
    return "{name:$name,author:$author,albumtitle:$albumtitle,albumlink:$albumlink}";
  }
}
