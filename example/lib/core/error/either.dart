/// Zero-dependency functional Either implementation using Dart sealed classes.
sealed class Either<L, R> {
  const Either();

  bool get isLeft => this is Left<L, R>;
  bool get isRight => this is Right<L, R>;

  T fold<T>(T Function(L left) fnL, T Function(R right) fnR);
}

final class Left<L, R> extends Either<L, R> {
  final L value;
  const Left(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnL(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Left && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

final class Right<L, R> extends Either<L, R> {
  final R value;
  const Right(this.value);

  @override
  T fold<T>(T Function(L left) fnL, T Function(R right) fnR) => fnR(value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Right && other.value == value;

  @override
  int get hashCode => value.hashCode;
}

/// Unit type to represent void in functional operations.
class Unit {
  const Unit._();
}
const unit = Unit._();
