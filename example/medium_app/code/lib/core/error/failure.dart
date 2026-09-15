/// Base class for all domain failure representations.
abstract class Failure {
  final String message;
  final int? statusCode;

  const Failure({required this.message, this.statusCode});

  @override
  String toString() => '$runtimeType(message: $message, statusCode: $statusCode)';
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.message = 'Sessão expirada. Faça login novamente.', super.statusCode = 401});
}

class ConnectionFailure extends Failure {
  const ConnectionFailure({super.message = 'Sem conexão com o servidor. Verifique sua internet.'});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

class UnknownFailure extends Failure {
  final StackTrace? stackTrace;
  const UnknownFailure({required super.message, this.stackTrace});
}
