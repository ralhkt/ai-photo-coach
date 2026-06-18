enum PhotoFrameTemplate {
  portraitPost,
  story,
  squarePost,
  landscapePost,
  classicPortrait,
}

extension PhotoFrameTemplateX on PhotoFrameTemplate {
  double get aspectRatio {
    return switch (this) {
      PhotoFrameTemplate.portraitPost => 4 / 5,
      PhotoFrameTemplate.story => 9 / 16,
      PhotoFrameTemplate.squarePost => 1.0,
      PhotoFrameTemplate.landscapePost => 16 / 9,
      PhotoFrameTemplate.classicPortrait => 3 / 4,
    };
  }

  PhotoFrameTemplate get next {
    final values = PhotoFrameTemplate.values;
    return values[(index + 1) % values.length];
  }
}