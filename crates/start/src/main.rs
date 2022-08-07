#![no_std]
#![no_main]

use core::panic::PanicInfo;

use bootloader::BootInfo;

static HELLO: &[u8] = b"Hello World!";

bootloader::entry_point!(main);

pub fn main(_boot_info: &'static BootInfo) -> ! {
    let vga_buffer = 0xb8000 as *mut u8;

    for (i, &byte) in HELLO.iter().enumerate() {
        unsafe {
            *vga_buffer.offset(i as isize * 2) = byte;
            *vga_buffer.offset(i as isize * 2 + 1) = 0xb;
        }
    }

    loop {}
}

#[panic_handler]
fn panic(_: &PanicInfo) -> ! {
    loop {}
}