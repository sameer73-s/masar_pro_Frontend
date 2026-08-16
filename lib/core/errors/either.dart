class Either<L, R> {
  final L? left;
  final R? right;

  Either({this.left, this.right})
    : assert(
        (left != null) != (right != null),
        'Either left or right must be non-null, but not both.',
      );

  Either.left(this.left) : right = null;
  Either.right(this.right) : left = null;

  bool get isLeft => left != null;
  bool get isRight => right != null;

  T fold<T>(T Function(L left) leftFunc, T Function(R right) rightFunc) {
    if (isLeft) {
      return leftFunc(left as L);
    } else {
      return rightFunc(right as R);
    }
  }
}
