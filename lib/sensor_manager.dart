import 'dart:math' as math;

/// 计算摄像头正对方位的 方位角，需要使用库  sensors_plus: ^3.0.2
class SensorManager {
  /// 从安卓复制过来的
  static bool getRotationMatrix(List<double?>? R, List<double?>? I,
      List<double> gravity, List<double> geomagnetic) {
    double Ax = gravity[0];
    double Ay = gravity[1];
    double Az = gravity[2];

    final double normsqA = (Ax * Ax + Ay * Ay + Az * Az);
    const double g = 9.81;
    const double freeFallGravitySquared = 0.01 * g * g;
    if (normsqA < freeFallGravitySquared) {
      // gravity less than 10% of normal value
      return false;
    }

    final double Ex = geomagnetic[0];
    final double Ey = geomagnetic[1];
    final double Ez = geomagnetic[2];
    double Hx = Ey * Az - Ez * Ay;
    double Hy = Ez * Ax - Ex * Az;
    double Hz = Ex * Ay - Ey * Ax;
    final double normH = math.sqrt(Hx * Hx + Hy * Hy + Hz * Hz);

    if (normH < 0.1) {
      // device is close to free fall (or in space?), or close to
      // magnetic north pole. Typical values are  > 100.
      return false;
    }
    final double invH = 1.0 / normH;
    Hx *= invH;
    Hy *= invH;
    Hz *= invH;
    final double invA = 1.0 / math.sqrt(Ax * Ax + Ay * Ay + Az * Az);
    Ax *= invA;
    Ay *= invA;
    Az *= invA;
    final double Mx = Ay * Hz - Az * Hy;
    final double My = Az * Hx - Ax * Hz;
    final double Mz = Ax * Hy - Ay * Hx;
    if (R != null) {
      if (R.length == 9) {
        R[0] = Hx;
        R[1] = Hy;
        R[2] = Hz;
        R[3] = Mx;
        R[4] = My;
        R[5] = Mz;
        R[6] = Ax;
        R[7] = Ay;
        R[8] = Az;
      } else if (R.length == 16) {
        R[0] = Hx;
        R[1] = Hy;
        R[2] = Hz;
        R[3] = 0;
        R[4] = Mx;
        R[5] = My;
        R[6] = Mz;
        R[7] = 0;
        R[8] = Ax;
        R[9] = Ay;
        R[10] = Az;
        R[11] = 0;
        R[12] = 0;
        R[13] = 0;
        R[14] = 0;
        R[15] = 1;
      }
    }
    if (I != null) {
      // compute the inclination matrix by projecting the geomagnetic
      // vector onto the Z (gravity) and X (horizontal component
      // of geomagnetic vector) axes.
      final double invE = 1.0 / math.sqrt(Ex * Ex + Ey * Ey + Ez * Ez);
      final double c = (Ex * Mx + Ey * My + Ez * Mz) * invE;
      final double s = (Ex * Ax + Ey * Ay + Ez * Az) * invE;
      if (I.length == 9) {
        I[0] = 1;
        I[1] = 0;
        I[2] = 0;
        I[3] = 0;
        I[4] = c;
        I[5] = s;
        I[6] = 0;
        I[7] = -s;
        I[8] = c;
      } else if (I.length == 16) {
        I[0] = 1;
        I[1] = 0;
        I[2] = 0;
        I[4] = 0;
        I[5] = c;
        I[6] = s;
        I[8] = 0;
        I[9] = -s;
        I[10] = c;
        I[3] = I[7] = I[11] = I[12] = I[13] = I[14] = 0;
        I[15] = 1;
      }
    }
    return true;
  }

  /// 从安卓复制过来的
  static bool remapCoordinateSystem(
      List<double?> inR, int X, int Y, List<double?> outR) {
    if (inR == outR) {
      final List<double> temp = [];
      // we don't expect to have a lot of contention
      if (remapCoordinateSystemImpl(inR, X, Y, temp)) {
        final int size = outR.length;
        for (int i = 0; i < size; i++) {
          outR[i] = temp[i];
        }
        return true;
      }
    }
    return remapCoordinateSystemImpl(inR, X, Y, outR);
  }

  /// 从安卓复制过来的
  static bool remapCoordinateSystemImpl(
      List<double?> inR, int X, int Y, List<double?> outR) {
    /*
         * X and Y define a rotation matrix 'r':
         *
         *  (X==1)?((X&0x80)?-1:1):0    (X==2)?((X&0x80)?-1:1):0    (X==3)?((X&0x80)?-1:1):0
         *  (Y==1)?((Y&0x80)?-1:1):0    (Y==2)?((Y&0x80)?-1:1):0    (Y==3)?((X&0x80)?-1:1):0
         *                              r[0] ^ r[1]
         *
         * where the 3rd line is the vector product of the first 2 lines
         *
         */

    final int length = outR.length;
    if (inR.length != length) {
      return false; // invalid parameter
    }
    if ((X & 0x7C) != 0 || (Y & 0x7C) != 0) {
      return false; // invalid parameter
    }
    if (((X & 0x3) == 0) || ((Y & 0x3) == 0)) {
      return false; // no axis specified
    }
    if ((X & 0x3) == (Y & 0x3)) {
      return false; // same axis specified
    }

    // Z is "the other" axis, its sign is either +/- sign(X)*sign(Y)
    // this can be calculated by exclusive-or'ing X and Y; except for
    // the sign inversion (+/-) which is calculated below.
    int Z = X ^ Y;

    // extract the axis (remove the sign), offset in the range 0 to 2.
    final int x = (X & 0x3) - 1;
    final int y = (Y & 0x3) - 1;
    final int z = (Z & 0x3) - 1;

    // compute the sign of Z (whether it needs to be inverted)
    final int axis_y = (z + 1) % 3;
    final int axis_z = (z + 2) % 3;
    if (((x ^ axis_y) | (y ^ axis_z)) != 0) {
      Z ^= 0x80;
    }

    final bool sx = (X >= 0x80);
    final bool sy = (Y >= 0x80);
    final bool sz = (Z >= 0x80);

    // Perform R * r, in avoiding actual muls and adds.
    final int rowLength = ((length == 16) ? 4 : 3);
    for (int j = 0; j < 3; j++) {
      final int offset = j * rowLength;
      for (int i = 0; i < 3; i++) {
        if (x == i) outR[offset + i] = getValue(sx, inR[offset + 0]);
        if (y == i) outR[offset + i] = getValue(sy, inR[offset + 1]);
        if (z == i) outR[offset + i] = getValue(sz, inR[offset + 2]);
      }
    }
    if (length == 16) {
      outR[3] = outR[7] = outR[11] = outR[12] = outR[13] = outR[14] = 0;
      outR[15] = 1;
    }
    return true;
  }

  static getValue(bool minus, double? value) {
    if (value == null) {
      return null;
    }

    return minus ? -value : value;
  }

  /// 从安卓复制过来的
  static List<double?> getOrientation(List<double?> R, List<double?> values) {
    /*
         * 4x4 (length=16) case:
         *   /  R[ 0]   R[ 1]   R[ 2]   0  \
         *   |  R[ 4]   R[ 5]   R[ 6]   0  |
         *   |  R[ 8]   R[ 9]   R[10]   0  |
         *   \      0       0       0   1  /
         *
         * 3x3 (length=9) case:
         *   /  R[ 0]   R[ 1]   R[ 2]  \
         *   |  R[ 3]   R[ 4]   R[ 5]  |
         *   \  R[ 6]   R[ 7]   R[ 8]  /
         *
         */
    if (R.length == 9) {
      values[0] = math.atan2(R[1]!, R[4]!);
      values[1] = math.asin(-R[7]!);
      values[2] = math.atan2(-R[6]!, R[8]!);
    } else {
      values[0] = math.atan2(R[1]!, R[5]!);
      values[1] = math.asin(-R[9]!);
      values[2] = math.atan2(-R[8]!, R[10]!);
    }

    return values;
  }

  /// 计算方位角
  static AzimuthEvent processOrientation(
      List<double> accelerometerValues, List<double> magneticFieldValues) {
    if (accelerometerValues.isNotEmpty && magneticFieldValues.isNotEmpty) {
      List<double?> values = [null, null, null];
      List<double?> R = [null, null, null, null, null, null, null, null, null];

      // 调用getRotaionMatrix获得变换矩阵R[]
      getRotationMatrix(R, null, accelerometerValues, magneticFieldValues);

      List<double?> adjustedRotationMatrix = [
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null,
        null
      ];

      /// 1（SensorManager.AXIS_X） 和 3（SensorManager.AXIS_Z） 是写死的，对应安卓原生里的常量
      remapCoordinateSystem(R, 1, 3, adjustedRotationMatrix);

      getOrientation(adjustedRotationMatrix, values); // 得到的values值为弧度

      // Convert to degrees
      double? azimuthRadians = values[0] ?? 0;
      double azimuthDegrees = azimuthRadians * (180 / math.pi);

      // Keep the value within [0, 360)
      double previousAzimuthDegrees = azimuthDegrees % 360;
      if (previousAzimuthDegrees < 0) {
        previousAzimuthDegrees += 360;
      }

      return AzimuthEvent(azimuthRadians, previousAzimuthDegrees);
    } else {
      return AzimuthEvent(0, 0);
    }
  }
}

class AzimuthEvent {
  AzimuthEvent(this.radian, this.angle);

  /// 弧度
  final double radian;

  /// 角度
  final double angle;

  @override
  String toString() => '[AzimuthEvent (angle: $angle, radian: $radian,)]';
}
