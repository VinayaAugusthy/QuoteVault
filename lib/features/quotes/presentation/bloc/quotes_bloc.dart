import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  QuotesBloc() : super(QuotesInitial()) {
    on<QuotesEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
