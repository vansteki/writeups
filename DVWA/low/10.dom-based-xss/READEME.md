# Weak Session IDs
### Objective: This module uses four different ways to set the dvwaSession cookie value, the objective of each level is to work out how the ID is
generated and then infer the IDs of other system users.

## 觀察

```
dvwaSession: 1
```
```
dvwaSession: 2
```
```
dvwaSession: 3
```

可以很明顯地看出 dvwaSession 是遞增的

這邊我暫時不知道要幹嘛，可能難度高一點的等級要分析 session ID 隨機性或 pattern 之類的 
