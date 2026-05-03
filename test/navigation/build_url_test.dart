import 'package:flutter_test/flutter_test.dart';
import 'package:jetx/jetx.dart';

void main() {
  group('Jet.buildUrl', () {
    test('substitutes single :param', () {
      expect(
        Jet.buildUrl('/user/:id', pathParams: {'id': 42}),
        '/user/42',
      );
    });

    test('substitutes multiple :params', () {
      expect(
        Jet.buildUrl('/user/:id/posts/:postId',
            pathParams: {'id': 42, 'postId': 9}),
        '/user/42/posts/9',
      );
    });

    test('appends query params and url-encodes them', () {
      expect(
        Jet.buildUrl('/items', queryParams: {'sort': 'asc', 'page': 2}),
        '/items?sort=asc&page=2',
      );
      expect(
        Jet.buildUrl('/search', queryParams: {'q': 'hello world'}),
        '/search?q=hello+world',
      );
    });

    test('combines path and query params', () {
      expect(
        Jet.buildUrl('/user/:id',
            pathParams: {'id': 42},
            queryParams: {'tab': 'profile'}),
        '/user/42?tab=profile',
      );
    });

    test('skips null query values', () {
      expect(
        Jet.buildUrl('/items',
            queryParams: {'sort': 'asc', 'filter': null}),
        '/items?sort=asc',
      );
    });

    test('returns pattern unchanged when no params', () {
      expect(Jet.buildUrl('/home'), '/home');
    });

    test('throws ArgumentError when :param missing from pathParams', () {
      expect(
        () => Jet.buildUrl('/user/:id'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => Jet.buildUrl('/user/:id/posts/:postId',
            pathParams: {'id': 42}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('url-encodes path param values', () {
      expect(
        Jet.buildUrl('/q/:term', pathParams: {'term': 'hello world'}),
        '/q/hello%20world',
      );
    });

    test('appends with & when pattern already contains ?', () {
      expect(
        Jet.buildUrl('/items?initial=1', queryParams: {'sort': 'asc'}),
        '/items?initial=1&sort=asc',
      );
    });
  });
}
