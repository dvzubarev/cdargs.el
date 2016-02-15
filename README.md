# cdargs.el
Fork of emacs front-end to personal bookmarks file

## Usage
`M-x cdargs`

## Open bookmarks
You can customize what an action to do with chosen directory by 
customizing `cdargs-find-file-function` (by default it is set to `find-file`).

## Dired
If you call cdargs in dired and then choose bookmarked directory,
your previous dired buffer will be killed. It can be customized by
setting `cdargs-dired-find-file-function` variable (`find-alternate-file` by default).

## Tramp
Tramp is supported. You may call cdargs from a remote file or a directory in dired and jump to a remote one.
