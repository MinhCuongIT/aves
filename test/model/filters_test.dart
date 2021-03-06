import 'package:aves/model/filters/album.dart';
import 'package:aves/model/filters/favourite.dart';
import 'package:aves/model/filters/filters.dart';
import 'package:aves/model/filters/location.dart';
import 'package:aves/model/filters/mime.dart';
import 'package:aves/model/filters/query.dart';
import 'package:aves/model/filters/tag.dart';
import 'package:aves/ref/mime_types.dart';
import 'package:test/test.dart';

void main() {
  test('Filter serialization', () {
    CollectionFilter jsonRoundTrip(filter) => CollectionFilter.fromJson(filter.toJson());

    final album = AlbumFilter('path/to/album', 'album');
    expect(album, jsonRoundTrip(album));

    final fav = FavouriteFilter();
    expect(fav, jsonRoundTrip(fav));

    final location = LocationFilter(LocationLevel.country, 'France${LocationFilter.locationSeparator}FR');
    expect(location, jsonRoundTrip(location));

    final mime = MimeFilter(MimeTypes.anyVideo);
    expect(mime, jsonRoundTrip(mime));

    final query = QueryFilter('some query');
    expect(query, jsonRoundTrip(query));

    final tag = TagFilter('some tag');
    expect(tag, jsonRoundTrip(tag));
  });
}
