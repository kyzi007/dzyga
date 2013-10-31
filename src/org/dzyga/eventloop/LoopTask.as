package org.dzyga.eventloop {
    import org.dzyga.callbacks.TaskState;

    public class LoopTask extends LoopTaskBasic {
        public function LoopTask (loop:Loop = null) {
            super(loop);
        }

        override protected function loopCallbackRegister ():void {
            if (!_loopCallback) {
                _loopCallback = _loop.call(runner, priority);
            }
        }

        protected function runner ():void {
            if (state == TaskState.STARTED) {
                _result = run.apply(thisArg, argsArray);
                _loopCallback = null;
            }
            if (state == TaskState.STARTED) {
                loopCallbackRegister();
            }
        }
    }
}
