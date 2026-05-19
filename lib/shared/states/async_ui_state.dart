sealed class AsyncUiState<T> {
  const AsyncUiState();
}

class AsyncInitial<T> extends AsyncUiState<T> {
  const AsyncInitial();
}

class AsyncLoading<T> extends AsyncUiState<T> {
  const AsyncLoading();
}

class AsyncSuccess<T> extends AsyncUiState<T> {
  const AsyncSuccess(this.data);

  final T data;
}

class AsyncFailure<T> extends AsyncUiState<T> {
  const AsyncFailure(this.message);

  final String message;
}
