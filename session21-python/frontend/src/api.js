export async function request(path, options = {}) {
  let response;
  try {
    response = await fetch(path, {
      ...options,
      signal: options.signal
        ? AbortSignal.any([options.signal, AbortSignal.timeout(15000)])
        : AbortSignal.timeout(15000),
      headers: { "Content-Type": "application/json", ...options.headers },
    });
  } catch (error) {
    if (options.signal?.aborted) throw error;
    throw new Error(options.method && options.method !== "GET"
      ? "Request outcome unknown. Close this dialog and refresh the ledger before retrying."
      : "Could not reach the server. Check the connection and try again.");
  }
  if (!response.ok) {
    let data;
    try {
      data = await response.json();
    } catch {
      throw new Error(
        "Server request failed. Refresh the ledger before retrying.",
      );
    }
    throw new Error(
      Array.isArray(data.detail)
        ? data.detail
            .map((error) => error.loc.at(-1) + ": " + error.msg)
            .join("; ")
        : data.detail || "Request failed",
    );
  }
  return response.status === 204 ? null : response.json();
}
