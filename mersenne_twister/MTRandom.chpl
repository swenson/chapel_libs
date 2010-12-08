/*
  Mersenne Twister random number generator for Chapel.
  Author: Christopher Swenson

  Uses a Mersenne Twister written in C to provide functionality similar to the
  Random module.

  For more information on the Mersenne Twister, see
    http://en.wikipedia.org/wiki/Mersenne_twister

  Basic usage:

  var r = new MTRandom();
  r.random(); // returns a real(64) betwen 0.0 and 1.0
  r.randint(); // returns a random int(32)
  f.fill(arr); // fills an array with random values, depending on its type

  By default, the MTRandom will generate all random numbers in a single-threaded fashion.
  
  This code is about 2-3x slower than the Random.chpl standard library, but has much
  higher quality pseudorandomness (good for simulations).

  If you hate yourself and want to have use multiple threads on multiple locales trying to
  generate random numbers, you can do
  
  var r = new MTRandom(parallel=true);
  
  Which will give one that uses forall's and sync variables, but it is very slow.

  Compile the code that you want to use with MTRandom like this:

    chpl -o whatever whatever.chpl [...] MTRandom.chpl mersenne_twister.c mersenne_twister.h

  Open issues:
    * Do something faster for multiple threads on multiple locales.  Like, run one thread
      per local to populate an array, and use a domain map to figure out which pieces
      should be populated by which locale.
    * Would there be a speed penalty by moving the C code into Chapel?
    * Implement the 64-bit MT for better performance on real(64) and uint(64) types.

  Here is a sample Chapel program that uses the MTRandom module

  use Time;
  use MTRandom;

  def main() {
    var arr: [1..100000] real;
    var t = new Timer();
    var r = new MTRandomStream();
    t.start();
    r.fillRandom(arr);
    t.stop();
    writeln(t.elapsed(TimeUnits.microseconds));
    for x in 1..10 do 
      writeln(r.random());
  }
*/

module MTRandom {
  use Time;

  // Types
  _extern type uint32 = uint(32);
  _extern type uint64 = uint(64);
  _extern type float = real(32);
  _extern type double = real(64);
  _extern type mt_state_s;
  _extern type mt_state_t = 1 * mt_state_s;

  // C Functions
  _extern def mt_init(inout state:mt_state_t, seed:int);
  _extern def mt_get_uint32(inout state:mt_state_t): uint32;
  _extern def mt_get_uint64(inout state:mt_state_t): uint64;
  _extern def mt_get_float(inout state:mt_state_t): float;
  _extern def mt_get_double(inout state:mt_state_t): double;

  // main class
  class MTRandomStream {
    var parallel: bool;
    var states: [LocaleSpace] mt_state_t;
    var locks$: [LocaleSpace] sync bool;

    pragma "inline"
    def state {
      if parallel then
        return states[here.id];
      else
        return states[0];
    }
    /* A seed of 0 means to generate a seed based on the time of day and the locale.
       The parallel bool means that we want to use parallel iterators to create the data, for
       which we have to pay a significant cost for sync variables.
    */
    def MTRandomStream(in seed=0, parallel=false) {
      this.parallel = parallel;
      if parallel {
        coforall l in Locales {
          on l {
            locks$[here.id] = true;
            if seed == 0 then
              seed = (floor(chpl_now_time()):int(64) - here.id * 652969):int;

            mt_init(states[here.id], seed);
          }
        }
      }
      else
      {
        if seed == 0 then
          seed = (floor(chpl_now_time()):int(64)):int;
        mt_init(states[0], seed);
      }
    }

    def mt_get_complex() {
      var ret: complex;
      if parallel then
        locks$[here.id];

      ret = mt_get_double(state) + mt_get_double(state) * 1i;

      if this.parellel then
        locks$[here.id] = true;
      return ret;
    }

    def mt_get_imag() {
      var ret: complex;
      if parallel then
        locks$[here.id];

      ret = mt_get_double(state) * 1i;
      if parallel then 
        locks$[here.id] = true;

      return ret;
    }

    def random() {
      var ret: real(64);
      if parallel then 
        locks$[here.id];

      ret = mt_get_double(states[here.id]);

      if parallel then
        locks$[here.id] = true;

      return ret;
    }

    def randint32() {
      var ret: int(32);
      if parallel then
        locks$[here.id];

      ret = mt_get_uint32(states[here.id]):int;

      if parallel then
        locks$[here.id] = true;

      return ret;
    }

    def fillRandom(x:[]) where x.eltType == complex {
      if parallel then
      forall a in x.domain do
        x[a] = mt_get_complex();
      else
      for a in x.domain do
        x[a] = mt_get_complex();
    }
    def fillRandom(x:[]) where x.eltType == real {
      if parallel then
      forall a in x.domain do
        x[a] = random();
      else
      for a in x.domain do
        x[a] = random();
    }
    def fillRandom(x:[]) where x.eltType == imag {
      if parallel then
      forall a in x.domain do
        x[a] = mt_get_imag();
      else
      for a in x.domain do
        x[a] = mt_get_imag();
    }
    def fillRandom(x:[]) where x.eltType == uint32 {
      if parallel then
      forall a in x.domain do
        x[a] = mt_get_uint32();
      else
      forall a in x.domain do
        x[a] = mt_get_uint32();
    }
    def fillRandom(x:[]) where x.eltType == uint64 {
      if parallel then
      forall a in x.domain do
        x[a] = mt_get_uint64(state);
      else
      for a in x.domain do
        x[a] = mt_get_uint64(state);

    }
    def fillRandom(x:[]) where x.eltType == real(32) {
      if parallel then
      forall a in x.domain do
        x[a] = mt_get_float(state);
      else
      for a in x.domain do
        x[a] = mt_get_float(state);
    }

    def randint32(lower, upper):int {
      return floor(lower + (mt_get_double() * (upper - lower))):int;
    }
    def randint64():int(64) {
      return mt_get_uint64(state):int(64);
    }
    def randint64(lower:int(64), upper:int(64)) {
      return floor(lower + (mt_get_double() * (upper - lower))):int;
    }

  }
}

