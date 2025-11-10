import { compose, createStore, applyMiddleware } from 'redux';
import rootReducer from './reducers/rootReducer';
import { thunk } from 'redux-thunk';

// Use Redux DevTools Extension if available, otherwise use regular compose
const composeEnhancers =
  (typeof window !== 'undefined' && window.__REDUX_DEVTOOLS_EXTENSION_COMPOSE__) || compose;

export default function configureStore() {
  return createStore(
    rootReducer,
    composeEnhancers(applyMiddleware(thunk))
  );
}