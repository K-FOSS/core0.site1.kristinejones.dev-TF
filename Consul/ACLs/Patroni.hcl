service_prefix "${ServiceName}" {
  policy = "write"
}

key_prefix "${Prefix}/${ServiceName}" {
  policy = "write"
}

session_prefix "" {
  policy = "write"
}