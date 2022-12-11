use anyhow::Result;

use kv::*;
wit_bindgen_rust::import!("wit/kv_v0.2.0/kv.wit");
wit_error_rs::impl_error!(kv::Error);

fn main() -> Result<()> {
    let kv_store = Kv::open("try-spiderlightning")?;
    kv_store.set("key1", b"Hello, SpiderLightning!")?;
    kv_store.set("key2", b"How are you?")?;
    // show each messages
    println!(
        "{}",
        std::str::from_utf8(&kv_store.get("key1")?)?,
    );
    println!(
        "{}",
        std::str::from_utf8(&kv_store.get("key2")?)?,
    );
    Ok(())
}
