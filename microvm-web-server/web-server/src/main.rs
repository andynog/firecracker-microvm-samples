// A simple Hello World web-server
extern crate gotham;

use gotham::state::State;

const HELLO_WORLD: &'static str = "MicroVM says => Hello World!";

pub fn say_hello(state: State) -> (State, &'static str) {
    (state, HELLO_WORLD)
}

pub fn main() {
    let addr = "172.16.0.2:8080";
    println!("Listening for requests at http://{}", addr);
    gotham::start(addr, || Ok(say_hello))
}
