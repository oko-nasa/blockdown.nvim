```haskell
perfectSquares :: Int -> [Int]
perfectSquares = aux []
    where aux lst n
            | n > 0 = aux ((n*n):lst) (n-1)
            | otherwise = lst

main = do
    print $ perfectSquares 5
```


```python
N = 5
for n in map(lambda n : n*n, range(1,N)):
    print(n)
```

```rust
fn main() {
    println!("Hello world!");
}
```


``` c
#include <stdio.h>

#define N 5

int main() {
    for(int i = 0; i < N; i++)
        printf("%i ", i*i);
    printf("\n");
}
```

``` lua
for i = 1,5,1 do print(i*i) end
```
