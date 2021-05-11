```haskell
perfectSquares :: Int -> [Int]
perfectSquares = aux []
    where aux lst n
            | n > 0 = aux ((n*n):lst) (n-1)
            | otherwise = lst

main = do
    print $ perfectSquares 35
```


```python repl ipy
print("haha")
print("haha")
print("haha")
print("haha")

```


```rust
fn main() {
    println!("Hello world!");
}
```


[DUMP]: ./
``` c
#include <stdio.h>
#define N 5
int main() {
    for(int i = 0; i < N; i++)
        printf("%i ", i*i);
    printf("\n");
}
```

``` bash repl uca
echo "hi"
echo "hello2"
```
