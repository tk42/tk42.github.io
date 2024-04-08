---
title: Deadlocks will raise in sending/receiving channels without buffers on single goroutine
date: 2021-05-11
tags: Programming/Tech, Programming/Languages/Go, Programming/Concurrency
publish: true
---
In this post, we’ll mention about the behaviour of channel under a certain condition in golang.

# How channels work

Let’s take a look back to the basic behaviour of channels. To communicate between goroutines, we use mostly channels. Channels is like a queuing object working as FIFO and it can be used as a buffer.

For example, to make a channel queued `struct{}` is as follows

```go
ch := make(chan struct{})
```
or to make buffered channel whose size is 10 for example 
```go
ch := make(chan struct{}, 10)
```
To send/receive `struct{}`to the channel is respectively following
```go
ch <- struct{}{}  
v, ok := <- ch
```
`v` will be set as the `struct`stored, and `ok` is a boolean variable to indicate whether `ch` is closed or not.

As we know, we can be receive data even when the channel was closed like that
```go
close(ch)  
v, ok := <- ch
```
Otherwise `ok` would be a useless variable in this language behaviour. It’s important that we can be received data from closed channel.
```go
ch := make(chan struct{})  
close(ch)  
v, ok := <-ch  
fmt.Println("done", v, ok) // done {} false
```

[_Code Example in The Go Playground_](https://play.golang.org/p/0QNfHHOb3S8)

And you must close the channel exactly once.
```go
ch := make(chan struct{})  
close(ch)  
close(ch) // panic: close of closed channel
```
And the following behaviour of goroutine could annoy you.
```go
ch := make(chan struct{})go func() {  
  ch <- struct{}{}  
}()close(ch)  
v, ok := <-ch  
fmt.Printf("%v %v", v, ok) // {} falsetime.Sleep(time.Duration(100) * time.Millisecond) // panic: send on closed channel
```
[_Code Example in The Go Playground_](https://play.golang.org/p/nbosnA-VV43)

This panic error message looks something weird because we seem to receive struct from closed channels as we’ve seen before.

In fact, goroutine takes a quite bit time to launch parallelly. While launching another goroutine, the main goroutine will execute some lines which close the channel immediately in here.

So, the panic error raises due to the already closed channel.

Codes in the next will be safe because waiting for receiving the struct to be stored.

```go
ch := make(chan struct{})go func() {  
  ch <- struct{}{}  
}()v, ok := <-ch  
fmt.Printf("%v %v\n", v, ok) // {} trueclose(ch)  
   
v, ok = <-ch  
fmt.Printf("%v %v", v, ok) // {} false
```
or it’s also good idea that you use `defer` sentence not to forget to close the channel.
```go
ch := make(chan struct{})defer close(ch) // After running the code below, you can be sure that the channel will be closedgo func() {  
  ch <- struct{}{}  
}()v, ok := <-ch  
fmt.Printf("%v %v\n", v, ok) // {} true
```
# Deadlock

Now, what if nobody listens the channel, it will happen “deadlock”.
```go
package mainfunc main() {  
   messages := make(chan struct{})  
   messages <- struct{}{} // fatal error: all goroutines are asleep - deadlock!  
}
```
Deadlock will happen when senders or receivers are gone and moreover the next case which I had mention at the title!
```go
package mainimport (  
 "fmt"  
)func set(ch chan string) {  
 ch <- "hoge"  
}func main() {  
 ch := make(chan string, 10) // buffered!!  
 set(ch)  
 fmt.Printf("Hello, %v", <-ch) // Hello, hoge  
}
```
[_Code Example in The Go Playground_](https://play.golang.org/p/JARWuReOdC6)

In the case that the channel with restricted size of buffer, the runtime will keep to execute even when a single goroutine would be running.

Or it’s nice idea that another goroutine would set the channel as follows;

```go
package mainimport (  
 "fmt"  
)func set(ch chan string) {  
 ch <- "hoge"  
}func main() {  
 ch := make(chan string)  
 go set(ch) // another goroutine!  
 fmt.Printf("Hello, %v", <-ch) // Hello, hoge  
}
```
[_Code Example in The Go Playground_](https://play.golang.org/p/FGhVZ9CW0GL)

Well, take care in the case using channels without buffers! Have a nice golang life!

Reference: [Go言語 — バッファなしのチャンネルに送受信するとデッドロックが起こる理由](https://qiita.com/YumaInaura/items/943c24ffb64df5e01c65)
