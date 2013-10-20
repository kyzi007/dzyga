package org.dzyga.callbacks {
    import org.dzyga.events.*;
    import flash.errors.IllegalOperationError;

    import org.dzyga.callbacks.TaskState;

    import org.dzyga.utils.ArrayUtils;

    public class Task implements ITask {
        public function Task () {
        }

        /**
         * Override this function to replace promise with subclass.
         *
         * @param promise
         * @return
         */
        protected function getPromise (promise:IPromise):IPromise {
            return promise || new Promise();
        }

        /**
         * Override this function to replace promise with subclass.
         *
         * @param promise
         * @return
         */
        protected function getOnce(promise:IPromise):IPromise {
            return promise || new Once();
        }

        // Be lazy
        protected var _started:IPromise;

        /**
         * @inheritDoc
         */
        public function get started ():IPromise {
            _started = getOnce(_started);
            return _started;
        }

        protected var _done:IPromise;

        /**
         * @inheritDoc
         */
        public function get done ():IPromise {
            _done = getOnce(_done);
            return _done;
        }

        protected var _failed:IPromise;

        /**
         * @inheritDoc
         */
        public function get failed ():IPromise {
            _failed = getOnce(_failed);
            return _failed;
        }

        protected var _finished:IPromise;

        /**
         * @inheritDoc
         */
        public function get finished ():IPromise {
            _finished = getOnce(_finished);
            return _finished;
        }

        protected var _progress:IPromise;

        /**
         * @inheritDoc
         */
        public function get progress ():IPromise {
            _progress = getPromise(_progress);
            return _progress;
        }

        protected var _state:String = TaskState.IDLE;

        /**
         * @inheritDoc
         */
        public function get state ():String {
            return _state;
        }

        /**
         * @inheritDoc
         */
        public function get running ():Boolean {
            return _state == TaskState.STARTED;
        }

        /**
         * Override this function to pass additional arguments to callback.
         *
         * @param promise
         * @param argsArray
         * @return
         */
        protected function resolvePromise (promise:IPromise, argsArray:Array):IPromise {
            if (promise) {
                promise.resolve.apply(null, argsArray);
            }
            return promise;
        }

        /**
         * @inheritDoc
         */
        public function start (...args):ITask {
            if (_state == TaskState.STARTED) {
                throw new IllegalOperationError('Reject or resolve the task first. Current state - ' + _state);
            }
            _state = TaskState.STARTED;
            resolvePromise(_started, args);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function notify (...args):ITask {
            if (_state != TaskState.STARTED) {
                throw new IllegalOperationError('Start the task first. Current state - ' + _state);
            }
            resolvePromise(_progress, args);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function resolve (...args):ITask {
            _state = TaskState.RESOLVED;
            resolvePromise(_done, args);
            resolvePromise(_finished, args);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function reject (...args):ITask {
            _state = TaskState.REJECTED;
            resolvePromise(_failed, args);
            resolvePromise(_finished, args);
            return this;
        }

        protected function clearPromise (promise:IPromise):IPromise {
            if (promise) {
                promise.clear();
            }
            return promise;
        }

        protected function resetPromise(promise:IPromise):IPromise {
            if (promise && promise is Once) {
                Once(promise).reset();
            }
            return promise;
        }

        /**
         * @inheritDoc
         */
        public function clear ():ITask {
            clearPromise(_started);
            clearPromise(_progress);
            clearPromise(_done);
            clearPromise(_failed);
            clearPromise(_finished);
            _started = _progress = _done = _failed = _finished = undefined;
            _state = TaskState.IDLE;
            return this;
        }

        public function reset():ITask {
            resetPromise(_started);
            resetPromise(_done);
            resetPromise(_failed);
            resetPromise(_finished);
            _state = TaskState.IDLE;
            return this;
        }

        /**
         * @inheritDoc
         */
        public function startedCallbackRegister (callback:Function, once:Boolean = false, thisArg:* = null, argsArray:Array = null):ITask {
            started.callbackRegister(callback, once, thisArg, argsArray);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function startedCallbackRemove (callback:Function):ITask {
            started.callbackRemove(callback);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function progressCallbackRegister (callback:Function, once:Boolean = false, thisArg:* = null, argsArray:Array = null):ITask {
            progress.callbackRegister(callback, once, thisArg, argsArray);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function progressCallbackRemove (callback:Function):ITask {
            progress.callbackRemove(callback);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function doneCallbackRegister (callback:Function, once:Boolean = false, thisArg:* = null, argsArray:Array = null):ITask {
            done.callbackRegister(callback, once, thisArg, argsArray);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function doneCallbackRemove (callback:Function):ITask {
            done.callbackRemove(callback);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function failedCallbackRegister (callback:Function, once:Boolean = false, thisArg:* = null, argsArray:Array = null):ITask {
            failed.callbackRegister(callback, once, thisArg, argsArray);
            return this;
        }

        /**
         * @inheritDoc
         */
        public function failedCallbackRemove (callback:Function):ITask {
            failed.callbackRemove(callback);
            return this;
        }
    }
}
