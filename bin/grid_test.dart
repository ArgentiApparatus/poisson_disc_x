import 'dart:math';
import 'package:vector_math/vector_math.dart';
import 'package:poisson_disc_x/bridson_grid_test.dart';
import 'package:poisson_disc_x/grid_impls.dart';

void main() {

  int radii = 64; // Diagonal length of range in disc radii
  int runs = 512;
  Vector2 range = new Vector2.all(radii.toDouble()/SQRT2);

  List<Splat> splats = new List<Splat>();

  splats.add(new Splat(range, (a, b) => new ArrayGrid(a, b)));
  splats.add(new Splat(range, (a, b) => new ArrayGrid1(a, b)));
  //splats.add(new Splat(range, (a, b) => new ShiftGrid(a, b)));
  //splats.add(new Splat(range, (a, b) => new MapGrid(a, b)));
  //splats.add(new Splat(range, (a, b) => new LinkedGrid(a, b)));
  //splats.add(new Splat(range, (a, b) => new LinkedArrayGrid(a, b)));

  for(int r=0; r<runs; r++) {
    splats.shuffle();
    for(Splat s in splats) s.blag();
  }

  splats.sort((a, b) => a._sw.elapsedMilliseconds.compareTo(b._sw.elapsedMilliseconds));

  for(Splat s in splats) print(s);
}


class Splat {
  final BridsonGridTest bgt;
  final Stopwatch _sw = new Stopwatch();
  int _n = 0;
  Splat(Vector2 range, Function f): bgt = new BridsonGridTest(range, 1.0, f);
  void blag() {
    _n++;
    _sw.start();
    bgt.generateSamples();
    _sw.stop();
  }
  String toString() => '${bgt.grid}: ${(_sw.elapsedMilliseconds/_n).toStringAsFixed(1)}';
}
