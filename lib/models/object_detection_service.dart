import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as IMG;
import 'package:pytorch_lite/pytorch_lite.dart';

ObjectDetectionService get objectDetectionService =>
    Get.find<ObjectDetectionService>();

class ObjectDetectionService extends GetxService {
  Map<CVModelType, ModelConfiguration> get _configurations => {
        CVModelType.startReply: const ModelConfiguration(
          modelPath: 'assets/models/start_reply_icon.torchscript',
          labelPath: 'assets/labels/labels.txt',
          numberOfClasses: 1,
          imgW: 640,
          imgH: 640,
        ),
        CVModelType.sendReply: const ModelConfiguration(
          modelPath: 'assets/models/send_reply_button_model.torchscript',
          labelPath: 'assets/labels/labels.txt',
          numberOfClasses: 1,
          imgW: 640,
          imgH: 640,
        ),
        CVModelType.heartButton: const ModelConfiguration(
          modelPath: 'assets/models/heart_button_model.torchscript',
          labelPath: 'assets/labels/labels.txt',
          numberOfClasses: 1,
          imgW: 640,
          imgH: 640,
        ),
      };

  final _cachedModels = <CVModelType, ObjectModelSetUp>{};

  Future<void> init() async {
    try {
      final configurations = _configurations;
      final futures =
          configurations.entries.map((entry) => _loadModel(entry.key)).toList();
      await Future.wait(futures);
    } catch (e) {
      debugPrint('$e');
    }
  }

  //################################################

  Future<List<DetectionResult>?> detectHeartButton(Uint8List screenshot) async {
    return _detect(screenshot, CVModelType.heartButton);
  }

  Future<List<DetectionResult>?> detectStartReplyButton(
      Uint8List screenshot) async {
    return _detect(screenshot, CVModelType.startReply);
  }

  Future<List<DetectionResult>?> detectionSendReplyButton(
      Uint8List screenshot) async {
    return _detect(screenshot, CVModelType.sendReply);
  }

  Future<List<DetectionResult>> _detect(
    Uint8List screenshot,
    CVModelType modelType,
  ) async {
    final finalResult = <DetectionResult>[];
    final imgIn = IMG.decodePng(screenshot);
    if (imgIn == null) {
      debugPrint('$runtimeType decodeImage error...');
      return finalResult;
    }
    final imageW = imgIn.width;
    final imageH = imgIn.height;
    final bitmap = screenshot;
    final modelSetUp = await _getModel(modelType);
    if (modelSetUp == null) {
      debugPrint('$runtimeType model was not initialized');
      return finalResult;
    }
    final objDetect = await modelSetUp.model.getImagePrediction(
      bitmap,
      minimumScore: 0.1,
      iOUThreshold: 0.3,
    );

    for (var element in objDetect) {
      // raw
      final rawRect = {
        'left': element.rect.left,
        'top': element.rect.top,
        'width': element.rect.width,
        'height': element.rect.height,
        'right': element.rect.right,
        'bottom': element.rect.bottom,
      };
      final rawRes = {
        'score': element.score,
        'className': element.className,
        'class': element.classIndex,
        'rect': rawRect,
      };
      debugPrint('\n$rawRes\n');

      // translated

      final translatedRect = _translateCoordinates(
        rect: rawRect,
        imageWidth: imageW.toDouble(),
        imageHeight: imageH.toDouble(),
      );
      final translatedPyTorchRect = PyTorchRect(
        left: translatedRect['left'] ?? 0,
        right: translatedRect['right'] ?? 0,
        height: translatedRect['height'] ?? 0,
        width: translatedRect['width'] ?? 0,
        bottom: translatedRect['bottom'] ?? 0,
        top: translatedRect['top'] ?? 0,
      );
      final translated = ResultObjectDetection(
        rect: translatedPyTorchRect,
        classIndex: element.classIndex,
        score: element.score,
        className: element.className,
      );
      debugPrint('\n$translatedRect\n');
      final dx = translatedPyTorchRect.left + translatedPyTorchRect.width / 2;
      final dy = translatedPyTorchRect.top + translatedPyTorchRect.height / 2;
      final targetPosition = Offset(dx, dy);
      final bitmapMeasure = Offset(imageW.toDouble(), imageH.toDouble());
      final score = element.score;
      finalResult.add(DetectionResult(
        targetPosition: targetPosition,
        bitmapMeasure: bitmapMeasure,
        rawResult: element,
        translatedResult: translated,
        score: score,
      ));
    }

    return finalResult;
  }

  //###################################

  FutureOr<ObjectModelSetUp?> _getModel(CVModelType modelType) async {
    debugPrint('$runtimeType _getModel $modelType');
    if (_cachedModels.containsKey(modelType)) {
      return _cachedModels[modelType];
    }
    return _loadModel(modelType);
  }

  Future<ObjectModelSetUp?> _loadModel(CVModelType modelType) async {
    debugPrint('$runtimeType Start loading model $modelType');
    try {
      final configuration = _configurations[modelType];
      if (configuration == null) {
        return null;
      }
      final model = await PytorchLite.loadObjectDetectionModel(
        configuration.modelPath,
        configuration.numberOfClasses,
        configuration.imgW,
        configuration.imgH,
        labelPath: configuration.labelPath,
        objectDetectionModelType: ObjectDetectionModelType.yolov8,
      );

      final cachedModelSetUp = ObjectModelSetUp(modelType, model);
      _cachedModels[modelType] = cachedModelSetUp;
      debugPrint('$runtimeType Model loaded successfully');
      return cachedModelSetUp;
    } catch (e) {
      debugPrint('$runtimeType Error loading model: \n$e');
      return null;
    }
  }

  Map<String, double> _translateCoordinates({
    required Map<String, double> rect,
    required double imageWidth,
    required double imageHeight,
  }) {
    final leftRel = rect['left'] ?? 0.0;
    final topRel = rect['top'] ?? 0.0;
    final widthRel = rect['width'] ?? 0.0;
    final heightRel = rect['height'] ?? 0.0;
    final rightRel = rect['right'] ?? 0.0;
    final bottomRel = rect['bottom'] ?? 0.0;

    final leftAbs = (leftRel * imageWidth);
    final topAbs = (topRel * imageHeight);
    final widthAbs = (widthRel * imageWidth);
    final heightAbs = (heightRel * imageHeight);
    final rightAbs = (rightRel * imageWidth);
    final bottomAbs = (bottomRel * imageHeight);

    return {
      'left': leftAbs,
      'top': topAbs,
      'width': widthAbs,
      'height': heightAbs,
      'right': rightAbs,
      'bottom': bottomAbs
    };
  }

  //######################## testing ##########################
  /// for testing models
  ///

  Future<TestObjectDetectionResult?> testObjectDetection(
      Uint8List screenshot) async {
    final detRes = await detectStartReplyButton(screenshot);
    if (detRes == null) {
      debugPrint('Not detected...');
      return null;
    }
    final widget = await _generateResultWidget(
      screenshot,
      detRes.map((e) => e.translatedResult).toList(),
    );
    return TestObjectDetectionResult(detRes, widget);
  }

  /// for testing models - draws on bitmap rects and returns image widget
  Future<Widget?> _generateResultWidget(
    Uint8List screenshot,
    List<ResultObjectDetection?> recognitions,
  ) async {
    ui.Image image = await decodeImageFromList(screenshot);
    var pictureRecorder = ui.PictureRecorder();
    var canvas = Canvas(pictureRecorder);
    var paint = Paint();
    paint.isAntiAlias = true;
    var src = Rect.fromLTWH(
      0.0,
      0.0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    var dst = Rect.fromLTWH(
      0.0,
      0.0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    canvas.drawImageRect(image, src, dst, paint);
    if (recognitions.isNotEmpty) {
      final paintRect = Paint();
      paintRect.isAntiAlias = true;
      paintRect.color = Colors.red;
      paintRect.strokeCap = StrokeCap.square;
      paintRect.style = ui.PaintingStyle.stroke;
      paintRect.strokeWidth = 3;

      recognitions.forEach((item) {
        final rect = item?.rect;
        if (rect != null) {
          canvas.drawRect(
            Rect.fromLTWH(
              rect.left,
              rect.top,
              rect.width,
              rect.height,
            ),
            paintRect,
          );
        }
      });
    }

    var pic = pictureRecorder.endRecording();
    ui.Image img = await pic.toImage(image.width, image.height);
    var byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      return null;
    }
    var buffer = byteData.buffer.asUint8List();
    return Image.memory(
      buffer,
      fit: BoxFit.fill,
    );
  }
}

////////////////////

enum CVModelType {
  startReply,
  sendReply,
  heartButton,
}

class ObjectModelSetUp {
  final CVModelType modelType;
  final ModelObjectDetection model;

  ObjectModelSetUp(this.modelType, this.model);
}

class DetectionResult {
  final Offset targetPosition;
  final Offset bitmapMeasure;
  final double score;
  final ResultObjectDetection rawResult;
  final ResultObjectDetection translatedResult;

  DetectionResult({
    required this.targetPosition,
    required this.bitmapMeasure,
    required this.score,
    required this.rawResult,
    required this.translatedResult,
  });
}

class ModelConfiguration {
  final String modelPath;
  final int numberOfClasses;
  final int imgW;
  final int imgH;
  final String? labelPath;

  const ModelConfiguration({
    required this.modelPath,
    required this.numberOfClasses,
    required this.imgW,
    required this.imgH,
    this.labelPath,
  });
}

class TestObjectDetectionResult {
  final List<DetectionResult> result;
  final Widget? imageWidget;

  TestObjectDetectionResult(this.result, this.imageWidget);
}
