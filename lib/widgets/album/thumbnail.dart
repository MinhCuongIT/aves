import 'dart:math';
import 'dart:typed_data';

import 'package:aves/model/image_decode_service.dart';
import 'package:aves/model/image_entry.dart';
import 'package:aves/widgets/album/thumbnail_tags.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

class Thumbnail extends StatefulWidget {
  final ImageEntry entry;
  final double extent;
  final double devicePixelRatio;

  const Thumbnail({
    Key key,
    @required this.entry,
    @required this.extent,
    @required this.devicePixelRatio,
  }) : super(key: key);

  @override
  ThumbnailState createState() => ThumbnailState();
}

class ThumbnailState extends State<Thumbnail> {
  Future<Uint8List> _byteLoader;

  ImageEntry get entry => widget.entry;

  String get uri => widget.entry.uri;

  @override
  void initState() {
    super.initState();
    initByteLoader();
  }

  @override
  void didUpdateWidget(Thumbnail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (uri == oldWidget.entry.uri && widget.extent == oldWidget.extent) return;
    initByteLoader();
  }

  initByteLoader() {
    final dim = (widget.extent * widget.devicePixelRatio).round();
    _byteLoader = ImageDecodeService.getImageBytes(widget.entry, dim, dim);
  }

  @override
  void dispose() {
    ImageDecodeService.cancelGetImageBytes(uri);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fontSize = min(14.0, (widget.extent / 8).roundToDouble());
    final iconSize = fontSize * 2;
    return DefaultTextStyle(
      style: TextStyle(
        color: Colors.grey[200],
        fontSize: fontSize,
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade700,
            width: 0.5,
          ),
        ),
        child: FutureBuilder(
            future: _byteLoader,
            builder: (futureContext, AsyncSnapshot<Uint8List> snapshot) {
              final bytes = (snapshot.connectionState == ConnectionState.done && !snapshot.hasError) ? snapshot.data : kTransparentImage;
              return Stack(
                alignment: AlignmentDirectional.bottomStart,
                children: [
                  Hero(
                    tag: uri,
                    child: LayoutBuilder(builder: (context, constraints) {
                      // during hero animation back from a fullscreen image,
                      // the image covers the whole screen (because of the 'fit' prop and the full screen hero constraints)
                      // so we wrap the image to apply better constraints
                      final dim = min(constraints.maxWidth, constraints.maxHeight);
                      return Container(
                        alignment: Alignment.center,
                        constraints: BoxConstraints.tight(Size(dim, dim)),
                        child: bytes.length > 0
                            ? Image.memory(
                                bytes,
                                width: dim,
                                height: dim,
                                fit: BoxFit.cover,
                              )
                            : Icon(Icons.error),
                      );
                    }),
                  ),
                  if (entry.isVideo)
                    VideoTag(
                      entry: entry,
                      iconSize: iconSize,
                    )
                  else if (entry.isGif)
                    GifTag(iconSize: iconSize)
                  else if (entry.hasGps)
                    GpsTag(iconSize: iconSize)
                ],
              );
            }),
      ),
    );
  }
}