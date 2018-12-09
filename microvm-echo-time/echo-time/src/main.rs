// Prints the current time every 3 seconds and quits on Ctrl+C.
// This sample was inspired by an example from the crossbeam-channel crate
// https://github.com/crossbeam-rs/crossbeam/blob/master/crossbeam-channel/examples/stopwatch.rs

#[macro_use]
extern crate crossbeam_channel;
extern crate signal_hook;
extern crate chrono;

use std::io;
use std::thread;
use std::time::Duration;
use chrono::{Utc, Timelike};

use crossbeam_channel::{bounded, tick, Receiver};
use signal_hook::iterator::Signals;
use signal_hook::SIGINT;

// Creates a channel that gets a message every time `SIGINT` is signalled.
fn sigint_notifier() -> io::Result<Receiver<()>> {
    let (s, r) = bounded(100);
    let signals = Signals::new(&[SIGINT])?;

    thread::spawn(move || {
        for _ in signals.forever() {
            if s.send(()).is_err() {
                break;
            }
        }
    });

    Ok(r)
}

// Prints the current time.
fn show() {
    let now = Utc::now();
    let (is_pm, hour) = now.hour12();
    println!("The current UTC time is {:02}:{:02}:{:02} {}", hour, now.minute(), now.second(), if is_pm { "PM" } else { "AM" });

}

fn main() {
    let update = tick(Duration::from_secs(3));
    let ctrl_c = sigint_notifier().unwrap();
    println!("Echo current time every 3 seconds...\r\nTo exit hit Ctrl-C...");
    show();

    loop {
        select! {
            recv(update) -> _ => {
                show();
            }
            recv(ctrl_c) -> _ => {
                println!();
                println!("Exiting...Goodbye!");
                break;
            }
        }
    }
}