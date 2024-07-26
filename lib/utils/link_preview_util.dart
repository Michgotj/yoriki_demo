import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

class LinkPreviewUtil {
  static Future<PreviewImage?> getPreviewImageUrl(String src) async {
    var source = src;
    try {
      final uri = Uri.parse(source);
      final host = uri.host.replaceAll('/', '');

      // check if x.com
      if (host == 'x.com' || host == 'vxtwitter') {
        final imageLink = await _getXImage(source);
        if (imageLink != null) {
          return PreviewImage(url: imageLink);
        } else {
          return null;
        }
      }

      final info = await getPreviewData(source);
      final prImage = info.image;
      if (prImage == null || prImage.url.isEmpty) {
        return null;
      }
      final result = PreviewImage(
        url: prImage.url,
      );
      return result;
    } catch (e) {
      debugPrint('Error getting image: $e');
      return null;
    }
  }

  //using https://jsonlink.io
  static Future<String?> _getXImage(String link) async {
    try {
      var source = link.replaceFirst('x.com', 'vxtwitter.com');
      final apiKey = 'pk_2c87c1c83d3c7dc8b5447de327408f6a7ab74514'; // todo change key
      final uri = Uri(
          scheme: 'https',
          host: 'jsonlink.io',
          path: '/api/extract',
          queryParameters: {
            'url': source,
            'api_key': apiKey,
          });
      debugPrint('LinkPreviewUtil X uri: $uri');
      final request = http.Request('GET', uri);
      final resp = await request.send();
      if (resp.statusCode != 200) {
        debugPrint('LinkPreviewUtil X bad response');
      }
      final body = await resp.stream.bytesToString();
      debugPrint('LinkPreviewUtil X body: $body');
      final json = jsonDecode(body);
      final images = json['images'];
      debugPrint('LinkPreviewUtil X resp images: $images');
      final image = images.length > 0 ? images.first : null;
      debugPrint('LinkPreviewUtil X image $image');
      return image;
    } catch (e) {
      debugPrint('LinkPreviewUtil X exception');
      debugPrint('$e');
      return null;
    }
  }

  // As a bot and parse - on mobile does not work
  static Future<String?> _getXImageBot(String link) async {
    try {
      var source = link.replaceFirst('x.com', 'vxtwitter.com');
      final headers = {
        'User-Agent': 'googlebot',
        //'Host': 'x.com'
      };
      final uri = Uri.parse('$source');
      debugPrint('LinkPreviewUtil X uri: $uri');
      var request = http.Request('GET', uri);
      request.headers.addAll(headers);
      request.followRedirects = true;
      final resp = await request.send();
      //final resp = await http.get(uri, headers: headers);
      if (resp.statusCode != 200) {
        debugPrint('LinkPreviewUtil X bad response');
      }
      final body = await resp.stream.bytesToString();
      debugPrint('LinkPreviewUtil X body: $body');
      debugPrint('LinkPreviewUtil X req headers: ${resp.request?.headers}');
      if (body.isEmpty) {
        debugPrint('LinkPreviewUtil X body is empty');
      }
      final document = parse(body);
      final images = document
          .getElementsByTagName('meta')
          .where((element) => element.attributes['property'] == 'og:image')
          .map((item) => item.attributes['content'])
          .toList();

      final image = images.length > 0 ? images.first : null;
      debugPrint('LinkPreviewUtil X image $image');
      return image;
    } catch (e) {
      debugPrint('LinkPreviewUtil X exception');
      debugPrint('$e');
      return null;
    }
  }
}

class PreviewImage {
  final String url;

  PreviewImage({
    required this.url,
  });

  @override
  String toString() {
    return 'PreviewImage{url: $url}';
  }
}
