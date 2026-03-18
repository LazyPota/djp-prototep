import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TrustGauge extends StatelessWidget {
  final int score;
  final String riskLevel;

  const TrustGauge({
    super.key,
    required this.score,
    required this.riskLevel,
  });

  Color _getPointerColor(int score) {
    if (score <= 30) return Colors.red;
    if (score <= 70) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                startAngle: 180,
                endAngle: 0,
                showLabels: false,
                showTicks: false,
                radiusFactor: 1.0,
                axisLineStyle: const AxisLineStyle(
                  thickness: 20,
                  cornerStyle: CornerStyle.bothCurve,
                  color: Colors.transparent,
                ),
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: 30,
                    color: Colors.red,
                    startWidth: 20,
                    endWidth: 20,
                  ),
                  GaugeRange(
                    startValue: 30,
                    endValue: 70,
                    color: Colors.orange,
                    startWidth: 20,
                    endWidth: 20,
                  ),
                  GaugeRange(
                    startValue: 70,
                    endValue: 100,
                    color: Colors.green,
                    startWidth: 20,
                    endWidth: 20,
                  ),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: score.toDouble(),
                    needleColor: _getPointerColor(score),
                    tailStyle: TailStyle(
                      length: 0.18,
                      width: 8,
                      color: _getPointerColor(score),
                    ),
                    knobStyle: KnobStyle(
                      knobRadius: 0.08,
                      color: Colors.white,
                      borderColor: _getPointerColor(score),
                      borderWidth: 0.05,
                    ),
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Text(
                      '$score',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    angle: 90,
                    positionFactor: 0.5,
                  ),
                ],
              ),
            ],
          ),
        ),
        Text(
          riskLevel,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _getPointerColor(score),
          ),
        ),
      ],
    );
  }
}
