library bridson_grids;

import 'dart:math';
import 'dart:collection';
import 'package:vector_math/vector_math.dart';
import 'package:poisson_disc_x/grid_impls.dart';


class BridsonGridTest {

  static final int _CANDIDATE_ATTEMPTS = 30;
  static final double _TWOPI = 2.0 * PI;

  final Vector2 _range;
  final double _radius;
  final Grid _grid;
  final Queue<Vector2> _proc = new Queue<Vector2>();
  final List<Vector2> _samples = new List<Vector2>();
  final Random _random = new Random();

  Grid get grid => _grid;

  int _candidates;
  int get candidates => _candidates;

  BridsonGridTest(Vector2 range, double radius, Function grid)
      : _range = range,
        _radius = radius,
        _grid = grid(range, radius);

  Iterable<Vector2> generateSamples() {

    Vector2 next, cand;
    double rad, ang;
    int a;

    _candidates = 0;

    // Clear current list of samples
    _samples.clear();

    // Generate initial sample
    next = new Vector2(_range.x * _random.nextDouble(), _range.y * _random.nextDouble());
    _grid.add(next);
    _proc.add(next);
    _samples.add(next);

    while (_proc.isNotEmpty) {

      // Pull random sample from processing list
      next = _proc.removeFirst();

      // Generate candidate samples
      for (a = 0; a < _CANDIDATE_ATTEMPTS; a++) {

        _candidates++;

        // Candidate sample in annulus around current sample
        rad = _radius + (_radius * _random.nextDouble());
        ang = _TWOPI * _random.nextDouble();
        cand = new Vector2.copy(next)
            ..x += rad * sin(ang)
            ..y += rad * cos(ang);

        // If candidate not in existing sample discs nor outside range:
        //   Add to output and processing lists
        //   Place next sample back in processing list
        //   Stop testing candidates
        if (cand.x >= 0.0 && cand.y >= 0.0 && cand.x < _range.x && cand.y < _range.y && _grid.test(cand)) {
          _samples.add(cand);
          _proc.add(cand);
          _proc.add(next);
          break;
        }
      }
    }

    // Clean up
    _proc.clear();
    _grid.clear();

    // Return samples
    return _samples;
  }
}