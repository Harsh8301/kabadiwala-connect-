import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../ministry_controller.dart';
import '../widgets/common.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({required this.controller, super.key});
  final MinistryController controller;

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
  );
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      if (code != null && (code.startsWith('KWC-') ||
          RegExp(r'^(lot|batch):[0-9a-fA-F-]{36}$').hasMatch(code))) {
        setState(() => _isProcessing = true);
        await _scannerController.stop();
        await widget.controller.handleScannedLotId(code);
        if (mounted && widget.controller.api.token != null &&
            widget.controller.scannedAsset == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(widget.controller.lastError)));
          setState(() => _isProcessing = false);
          await _scannerController.start();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.controller.t('scanLotQr')),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => widget.controller.go(WorkflowScreen.home),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: _scannerController,
            onDetect: _onDetect,
          ),
          Container(
            decoration: ShapeDecoration(
              shape: QrScannerOverlayShape(
                borderColor: primary,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            child: Text(
              widget.controller.t('alignQrFrame'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  const QrScannerOverlayShape({
    this.borderColor = secondary,
    this.borderWidth = 3.0,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(getOuterPath(rect), Offset.zero);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }
    return getLeftTopPath(rect)
      ..lineTo(rect.right, rect.bottom)
      ..lineTo(rect.left, rect.bottom)
      ..lineTo(rect.left, rect.top);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final effectiveBorderLength =
        borderLength > cutOutSize / 2 ? cutOutSize / 2 : borderLength;
    final effectiveCutOutSize = cutOutSize;

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - effectiveCutOutSize / 2,
      rect.top + height / 2 - effectiveCutOutSize / 2,
      effectiveCutOutSize,
      effectiveCutOutSize,
    );

    canvas
      ..saveLayer(rect, backgroundPaint)
      ..drawRect(rect, backgroundPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius)),
        boxPaint,
      )
      ..restore();

    canvas
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.left, cutOutRect.top + effectiveBorderLength)
          ..lineTo(cutOutRect.left, cutOutRect.top + borderRadius)
          ..arcToPoint(
            Offset(cutOutRect.left + borderRadius, cutOutRect.top),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(cutOutRect.left + effectiveBorderLength, cutOutRect.top),
        borderPaint,
      )
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.right, cutOutRect.top + effectiveBorderLength)
          ..lineTo(cutOutRect.right, cutOutRect.top + borderRadius)
          ..arcToPoint(
            Offset(cutOutRect.right - borderRadius, cutOutRect.top),
            radius: Radius.circular(borderRadius),
          )
          ..lineTo(cutOutRect.right - effectiveBorderLength, cutOutRect.top),
        borderPaint,
      )
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.left, cutOutRect.bottom - effectiveBorderLength)
          ..lineTo(cutOutRect.left, cutOutRect.bottom - borderRadius)
          ..arcToPoint(
            Offset(cutOutRect.left + borderRadius, cutOutRect.bottom),
            radius: Radius.circular(borderRadius),
            clockwise: false,
          )
          ..lineTo(cutOutRect.left + effectiveBorderLength, cutOutRect.bottom),
        borderPaint,
      )
      ..drawPath(
        Path()
          ..moveTo(cutOutRect.right, cutOutRect.bottom - effectiveBorderLength)
          ..lineTo(cutOutRect.right, cutOutRect.bottom - borderRadius)
          ..arcToPoint(
            Offset(cutOutRect.right - borderRadius, cutOutRect.bottom),
            radius: Radius.circular(borderRadius),
            clockwise: true,
          )
          ..lineTo(cutOutRect.right - effectiveBorderLength, cutOutRect.bottom),
        borderPaint,
      );
  }

  @override
  ShapeBorder scale(double t) {
    return QrScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth,
      overlayColor: overlayColor,
    );
  }
}
