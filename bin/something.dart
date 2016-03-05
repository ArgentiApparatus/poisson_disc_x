import 'dart:math';
import 'dart:collection';

Random _random = new Random();

abstract class Thing {
  void setup(Iterable values);
  void biff();
}

class Nob = Object with LinkedListEntry;

class QueueThing implements Thing {
  Queue<Nob> _underlying = new Queue<Nob>();
  void setup(Iterable<Nob> values) { _underlying.clear(); _underlying.addAll(values); }
  void biff() {
    _underlying.add(_underlying.removeFirst());
  }
}

class ListThing implements Thing {
  List<Nob> _underlying = new List<Nob>();
  int _index;
  Nob _tmp;
  void setup(Iterable<Nob> values) { _underlying.clear(); _underlying.addAll(values); }
  void biff() {
    _index = _random.nextInt(_underlying.length);
    _tmp = _underlying.elementAt(_index);
    _underlying[_index] = _underlying.last;
    _underlying.removeLast();
    _underlying.add(_tmp);
  }
}

class LinkedListThing implements Thing {
  LinkedList<Nob> _underlying = new LinkedList<Nob>();
  void setup(Iterable<Nob> values) { _underlying.clear(); _underlying.addAll(values); }
  void biff() {
    Nob nob = _underlying.elementAt(_random.nextInt(_underlying.length));
    nob.unlink();
    _underlying.add(nob);
  }
}

class Splat {
  final Thing _thing;
  int _poo;
  final Stopwatch _sw = new Stopwatch();
  int _n = 0;
  Splat(this._thing, this._poo, Iterable<Nob> nobs) { _thing.setup(nobs); }
  void blag() {
    _n++;
    _sw.start();
    for(int i=0; i<_poo; i++) _thing.biff();
    _sw.stop();
  }
  String toString() => '${_thing}: ${(_sw.elapsedMilliseconds/_n).toStringAsFixed(3)}';
}


void main() {

  final int nobLength = 128;
  final int poo = 128;
  final int runs = 516;

  Iterable<Nob> nobs = new List.generate(nobLength, (_)=>new Nob());

  List<Splat> splats = new List<Splat>();
  splats.add(new Splat(new QueueThing(), poo, nobs));
  splats.add(new Splat(new ListThing(), poo, nobs));
  splats.add(new Splat(new LinkedListThing(), poo, nobs));

  for(int r=0; r<runs; r++) {
    splats.shuffle();
    for(Splat s in splats) s.blag();
  }

  splats.sort((a, b) => a._sw.elapsedMilliseconds.compareTo(b._sw.elapsedMilliseconds));

  for(Splat s in splats) print(s);
}