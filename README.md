Drop the script into your project to use it.
Then use the signals functions in your instances.

Initialize with signal_init().

Then add a signal to an instance using signal_add().

Connect to the signal from another instance with signal_connect() or signal_connect_user_event().

Emit the signal in from the instance owning the signal with signal_emit().
