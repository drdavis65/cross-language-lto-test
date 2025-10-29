fn main() {
    unsafe {
        let v = std::ffi::CStr::from_ptr(libz_sys::zlibVersion());
        println!("zlib version: {}", v.to_str().unwrap());
    }
}
