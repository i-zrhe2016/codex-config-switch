# 跨 provider 会话可见性排障

## 先确认入口

```bash
/root/.codex/bin/codex-profile-switch status
/root/.codex/bin/codex-profile-switch sessions
```

`sessions` 是只读检查，会显示 provider、时间、会话 ID 和截断标题。它读取当前 `CODEX_HOME` 下的本地会话索引，不会依赖当前 profile 的 provider 过滤。

## 常见问题

### 切换到官方后看不到 API 会话

不要只运行原生 `codex resume --all`；它在部分版本中仍可能只显示当前 provider。使用切换器的全 provider 入口：

```bash
/root/.codex/bin/codex-profile-switch use official --resume-all
```

如果只需要列出会话：

```bash
/root/.codex/bin/codex-profile-switch sessions
```

### `--resume-all` 提示需要交互终端

选择器需要 TTY。自动化或无交互环境应传入 `--last` 或已知的会话 ID：

```bash
/root/.codex/bin/codex-profile-switch use official --resume-all --last
/root/.codex/bin/codex-profile-switch use official --resume-all <SESSION_ID>
```

### 会话能看到，但继续执行失败

可见性和可继续执行是两件事。会话保留原 provider 元数据；`--resume-all` 只是用当前选定的 profile 打开它，不会把第三方上下文转换成官方 provider 格式。此时可以：

1. 确认当前 profile 与会话原 provider 是否兼容。
2. 用原 API profile 直接尝试继续：

   ```bash
   /root/.codex/bin/codex-profile-switch use api --resume-all <SESSION_ID>
   ```

3. 如果只需查看历史内容，不要创建新的“合并会话”，保留原始 rollout 文件。

### 列表为空或缺少很早的会话

当前 helper 使用 app-server 的 state DB 只读列表，默认排除已归档会话，并遵循 Codex 的交互会话来源过滤。检查：

```bash
printf 'CODEX_HOME=%s\n' "${CODEX_HOME:-/root/.codex}"
/root/.codex/bin/codex-profile-switch sessions
```

如果会话已归档，先在原生 Codex 中取消归档；如果只剩 rollout 文件但没有索引记录，先不要手工修改 SQLite 或 rollout，使用会话 ID 直接调用原生 `codex resume <SESSION_ID>` 并保留备份。

### 切换后 helper 启动失败

`--resume-all` 的顺序是“先切换 profile，再读取全 provider 列表”。因此失败时先检查：

```bash
/root/.codex/bin/codex-profile-switch status
test -x /root/.codex/bin/codex-session-list
command -v codex
```

如果需要恢复到原 profile，使用：

```bash
/root/.codex/bin/codex-profile-switch use api
# 或
/root/.codex/bin/codex-profile-switch use official
```

切换产生的备份位于 `/root/.codex/profiles/backups/<timestamp>/`，不要删除仍需回滚的备份。

## 最小验证清单

- `status` 能显示预期的 active profile。
- `sessions` 的列表中同时出现目标 provider。
- `--resume-all <SESSION_ID>` 能返回并调用对应 ID。
- 原始 `state_*.sqlite`、rollout JSONL 和 provider 元数据未被手工改写。
