use std::net::TcpListener;

#[tokio::main]
async fn main() -> std::io::Result<()> {
    let listener = TcpListener::bind("127.0.0.1:0").expect("Failed to bind random port");
    let port = listener.local_addr().unwrap().port();
    println!("{}", format!("http://127.0.0.1:{}", port));
    let server = zero2prod::run(listener).expect("Failed to bind address");
    server.await
}
