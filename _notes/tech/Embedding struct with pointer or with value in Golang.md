---
title: Embedding struct with pointer or with value in Golang
date: 2020-05-07
tags: 
publish: true
---
# TL;DR

・ネストした構造体の宣言/初期化方法でポインタが絡むとエラーメッセージが一見分かりにくい

・ネストした構造体にはドットで中身のフィールドにアクセスできるsyntax sugarがある

・ネストした構造体のどちらか一方でも値型でないとドットアクセスのsyntax sugarは利用できない

・newで構造体を初期化するとポインタ変数になる

・構造体をネストする時はsyntax sugarに制約ができる上，間違えるとsegmentation違反で派手に落ちるため，ちゃんと理解した上で使い分ける

私は Golang において構造体を埋め込む際に，値で埋め込む場合とポインタで埋め込む場合の挙動の違いで混同することがよくあります．

まず，おさらいですが値を引数にとる関数とポインタを引数にとる関数の違いを復習しておきましょう．

```go
package mainimport (  
 "fmt"  
)func AtaiTest(a int) {  
 a += 1  
 fmt.Println("aの値(関数内)：", a)  
}func PointerTest(a *int) {  
 *a += 1  
 fmt.Println("aの値(関数内)：", *a)  
}func main() {  
 a := 10  
 fmt.Println("最初のaの値：", a)  
 AtaiTest(a)  
 fmt.Println("AtaiTest()呼び出し後のaの値：", a)  
 PointerTest(&a)  
 fmt.Println("PointerTest()呼び出し後のaの値：", a)  
}
```

実行結果は

> 最初のaの値： 10  
> aの値(関数内)： 11  
> AtaiTest()呼び出し後のaの値： 10  
> aの値(関数内)： 11  
> PointerTest()呼び出し後のaの値： 11

[Go Playground - The Go Programming Language](https://play.golang.org/p/3eFy8yj1Uh4?source=post_page-----f2c252df63e5--------------------------------)

参考
[Golangのポインタ渡し初心者を卒業した #初心者 - Qiita](https://qiita.com/kotaonaga/items/4a93ec40718c279154f5?source=post_page-----f2c252df63e5--------------------------------)

値で渡された関数の中では変数を操作しても呼び出し元には影響がないが，ポインタで渡された関数の中では変数を操作すると呼び出し元の値も変わってしまします．

ポインタというのは”変数を格納しているメモリ空間のアドレス”だからです．

ところで，下記のコードを実行するとどうなるでしょうか？

```go
package mainimport (  
 "fmt"  
)type Abstract struct {  
 Name string  
}type Concrete struct {  
 *Abstract  
 Value int  
}func main() {  
 c := Concrete{}  
 c.Name = "Hoge"  
 c.Value = 1  
 fmt.Printf("Hello, %v and you are %v", c.Name, c.Value)  
}
```

実行結果は

> panic: runtime error: invalid memory address or nil pointer dereference  
> [signal SIGSEGV: segmentation violation code=0x1 addr=0x0 pc=0x492e94]  
>   
> goroutine 1 [running]:  
> main.main()  
> /tmp/sandbox997257165/prog.go:20 +0xe4

[Go Playground - The Go Programming Language](https://play.golang.org/p/ZfS2TQUqBzc?source=post_page-----f2c252df63e5--------------------------------)

segmentation 違反を起こしていますが，エラーメッセージが非常にわかりにくく一見何をしたのか分かりません．コンパイル時にも警告は現れないため，実行して初めて派手に壊れてしまうという**非常に危険な間違い**です．

単純化してあるため，このコード例ではすぐ間違いに気づくと思いますが，本当にやりたかったことは_Concrete_で宣言している_Abstract_構造体を値で渡してやれば実現できます．

```go
package mainimport (  
 "fmt"  
)type Abstract struct {  
 Name string  
}type Concrete struct {  
 Abstract  
 Value int  
}func main() {  
 c := Concrete{}  
 fmt.Printf("c type %v\n", reflect.TypeOf(c))  
 c.Name = "Hoge"  
 c.Value = 1  
 fmt.Printf("Hello, %v and you are %v", c.Name, c.Value)  
}
```

```
c type main.Concrete  
Hello, Hoge and you are 1
```
[Go Playground - The Go Programming Language](https://play.golang.org/p/MkX8dn0N26h?source=post_page-----f2c252df63e5--------------------------------)

\_\*Abstract_ はあくまでポインタ変数なので，\_Concrete_構造体に埋め込んだところで_Abstract_の内部変数であるところの_Name_まで初期化してはくれません．その結果_Concrete_構造体に_Name_という変数が未定義なので，segmentation 違反が発生しているのですね．

ところで，構造体の初期化方法にはstruct literalを用いる表現とそうでない表現があります．

struct literalを用いる表現では {} を用いた例えば次のようなものです．

```go
c := Concrete{  
  Abstract: Abstract{Name: "Hoge"},  
  Value: 1,  
 }
```

これ以外の表現とは先の例で見たように，フィールド毎に宣言していくもの


```go
c := Concrete{}  
c.Name = "Hoge"  
c.Value = 1
```

の他に，newを用いたものもあります．

```go
c := new(Concrete)  
c.Name = "Hoge"  
c.Value = 1
```

話を戻して，次に構造体の初期化を値変数とポインタ変数で変えてみましょう．

前準備として上記のコードをstruct literal表現に書き直してみましょう．

```go
package mainimport (  
 "fmt"  
 "reflect"  
)type Abstract struct {  
 Name string  
}type Concrete struct {  
 Abstract  
 Value int  
}func main() {  
 c := Concrete{  
  Abstract: Abstract{Name: "Hoge"},  
  Value: 1,  
 }  
 fmt.Printf("c type %v\n", reflect.TypeOf(c))  
 fmt.Printf("Hello, %v and you are %v", c.Name, c.Value)  
}
```

> c type main.Concrete  
> Hello, Hoge and you are 1

[Go Playground - The Go Programming Language](https://play.golang.org/p/JiW9VcW_p50?source=post_page-----f2c252df63e5--------------------------------)

変数の型を含め等価ですね．ここからわかることは

```go
c.Name = "Hoge"
```

は_Abstract_構造体の中の_Name_にアクセスしてくれる便利な**syntax suger**(糖衣構文)であるということです．

実際に（ネストしたAbstractをすっ飛ばして）\_Concrete_の中で_Name_変数にstruct literalの表現方法で宣言しようとしても_Name_という変数はないので怒られてしまいます．

```go
package mainimport (  
 "fmt"  
 "reflect"  
)type Abstract struct {  
 Name string  
}type Concrete struct {  
 Abstract  
 Value int  
}func main() {  
 c := Concrete{  
  Name: "Hoge",  
  Value: 1,  
 }  
 fmt.Printf("c type %v\n", reflect.TypeOf(c))  
 fmt.Printf("Hello, %v and you are %v", c.Name, c.Value)  
}
```

> ./prog.go:19:3: cannot use promoted field Abstract.Name in struct literal of type Concrete

この前提に立てば，記事の最初に例示したポインタ型変数_\*Abstract_をメンバに持つ_Concrete_の例で正しく実行しようとすれば，次のように変数宣言してあげれば良いことがわかります．
```go
package mainimport (  
 "fmt"  
 "reflect"  
)type Abstract struct {  
 Name string  
}type Concrete struct {  
 *Abstract  
 Value int  
}func main() {  
 c := Concrete{  
  Abstract: &Abstract{Name: "Hoge"},  
  Value: 1,  
 }  
 fmt.Printf("c type %v\n", reflect.TypeOf(c))  
 fmt.Printf("Hello, %v and you are %v", c.Name, c.Value)  
}```

> c type main.Concrete  
> Hello, Hoge and you are 1

[Go Playground - The Go Programming Language](https://play.golang.org/p/LHtW3MopB9J?source=post_page-----f2c252df63e5--------------------------------)

しかし，ややこしいことに_\*Abstract.Name_には実は_c.Name_で参照できてしまいます．先程のコード例の末尾に次を追加します．

```go
c.Name = "hogehoge"  
 fmt.Printf("Hello, %v and you are %v", c.Name, c.Value)
```

> Hello, hogehoge and you are 1

_c_ の型は値型ですが，\_Abstract_の型はポインタ型です．しかし，値型構造体の時と同様にドットで中身のフィールドにアクセスできるsyntax sugarが用意されているんですね．

---

また，構造体をnewで初期化した場合は**ポインタ変数で構造体が初期化されてしまう**ようです．

```go
package mainimport (  
 "fmt"  
 "reflect"  
)type Abstract struct {  
 Name string  
}type Concrete struct {  
 Abstract  
 Value int  
}func main() {  
 c := new(Concrete)  
 fmt.Printf("c type %v\n", reflect.TypeOf(c))  
 c.Name = "Hoge"  
 c.Value = 1  
 fmt.Printf("Hello, %v and you are %v", c.Name, c.Value)  
}
```

> c type *main.Concrete  
> Hello, Hoge and you are 1

[Go Playground - The Go Programming Language](https://play.golang.org/p/ig13NMp4WvU?source=post_page-----f2c252df63e5--------------------------------)

今度は先程とは逆で，_c_ の型はポインタ型ですが，_Abstract_の型は値型です．しかし，この場合もドットで中身のフィールドにアクセスできるsyntax sugarが用意されています．

ポインタ変数で初期化されているにも関わらず，そのような挙動を示さないのは親切というよりも罠のように見えるのですが気のせいでしょうか．

---

さて，ここまで来たら調べておきましょう，ポインタ型構造体をポインタ型構造体でネストした場合のドットアクセスは

```go
package mainimport (  
 "fmt"  
 "reflect"  
)type Abstract struct {  
 Name string  
}type Concrete struct {  
 *Abstract  
 Value int  
}func main() {  
 c := new(Concrete)  
 fmt.Printf("c type %v\n", reflect.TypeOf(c))  
 c.Name = "Hoge"  
 c.Value = 1  
 fmt.Printf("Hello, %v and you are %v", c.Name, c.Value)  
}
```

c type \*main.Concrete  
panic: runtime error: invalid memory address or nil pointer dereference  
\[signal SIGSEGV: segmentation violation code=0x1 addr=0x8 pc=0x492e8f\]

[Go Playground - The Go Programming Language](https://play.golang.org/p/vu58bO9aZ3I?source=post_page-----f2c252df63e5--------------------------------)

ダメでした．どちらか一方でも値型の構造体でないとこのsyntax sugarは利用できないようです．

# 所感

構造体をネストする過程で，構造体の初期化方法とそのsyntax sugerの挙動について理解しておかないと，実行時にsegmentation違反が発生し得ることを例をあげて説明しました．これからは意識して使い分けていきたいです．

ちなみに，ネストした構造体の型を値・ポインタにすることの方針については下記のstackoverflowが参考になりそうです．

[Embedding in Go with pointer or with value - Stack Overflow](https://stackoverflow.com/questions/28501976/embedding-in-go-with-pointer-or-with-value?source=post_page-----f2c252df63e5--------------------------------)

