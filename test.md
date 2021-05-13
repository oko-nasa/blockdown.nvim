```haskell
perfectSquares :: Int -> [Int]
perfectSquares = aux []
    where aux lst n
            | n > 0 = aux ((n*n):lst) (n-1)
            | otherwise = lst
main = do
    print $ perfectSquares 35
```

```python repl
print("hello")
print("hello")
print("hello")
print("hello")
```

```rust 0.2
fn main() {
    println!("Hola desde 0.2!");
}
```

[DUMP]: ./
[NAME]: ej1c
``` c
#include <stdio.h>
int main() {
    printf("Hola desde 0.1!\n");
}
```

``` bash repl
echo "hi"
echo "hello2"
```
