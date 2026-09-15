/// Zero-dependency functional Either type for robust error handling.
sealed class Either<L, R> {
  const Either();

  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight);

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  L? get leftOrNull => fold((l) => l, (_) => null);
  R? get rightOrNull => fold((_) => null, (r) => r);
}

final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) =>
      ifLeft(value);
}

final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  B fold<B>(B Function(L left) ifLeft, B Function(R right) ifRight) =>
      ifRight(value);
}
