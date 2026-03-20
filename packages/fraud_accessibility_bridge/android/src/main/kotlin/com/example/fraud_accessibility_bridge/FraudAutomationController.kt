package com.example.fraud_accessibility_bridge

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.GestureDescription
import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.graphics.Path
import android.graphics.Rect
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.view.Display
import android.view.accessibility.AccessibilityNodeInfo

internal object FraudAutomationController {

    fun runShareCopyFlow(
        service: FraudAccessibilityService,
        appContext: Context,
        timeoutMs: Long,
        callback: (Map<String, Any?>) -> Unit
    ) {
        val mainHandler = Handler(Looper.getMainLooper())
        var finished = false
        val clipboardBeforeRun = readClipboardText(appContext)

        fun finish(payload: Map<String, Any?>) {
            if (finished) return
            finished = true
            callback(payload)
        }

        mainHandler.postDelayed({
            finish(mapOf("status" to "error", "message" to "Timed out"))
        }, timeoutMs)

        mainHandler.post {
            val root = service.rootInActiveWindow
            if (root == null) {
                finish(mapOf("status" to "error", "message" to "No active window. Open a shopping app product page first."))
                return@post
            }

            val packageName = root.packageName?.toString()
            val isTokopedia = packageName?.contains("tokopedia", ignoreCase = true) == true

            val fallbackSize = screenSizeFromRoot(root)

            fun startFlowWithSize(width: Int, height: Int) {
                val shareCandidates = buildShareCandidates(width, height, isTokopedia)
                val copyCandidates = buildCopyCandidates(width, height, isTokopedia)

                fun completeWithClipboard() {
                    mainHandler.postDelayed({
                        val text = readClipboardText(appContext)
                        if (text.isNullOrBlank()) {
                            finish(mapOf("status" to "error", "message" to "Clipboard was empty after copying."))
                            return@postDelayed
                        }

                        if (!looksLikeUrl(text) && text == clipboardBeforeRun) {
                            finish(mapOf("status" to "error", "message" to "Copy action did not produce a product link."))
                            return@postDelayed
                        }

                        finish(mapOf("status" to "success", "copiedText" to text))
                    }, 800L)
                }

                fun attemptCopy(index: Int) {
                    if (finished) return

                    val rootNow = service.rootInActiveWindow
                    if (rootNow != null) {
                        val copyNode = findCopyLinkNode(rootNow)
                        if (copyNode != null && performClick(copyNode)) {
                            completeWithClipboard()
                            return
                        }
                    }

                    if (index >= copyCandidates.size) {
                        finish(mapOf("status" to "error", "message" to "Couldn't find a Copy Link option after opening share sheet."))
                        return
                    }

                    val (tapX, tapY) = copyCandidates[index]
                    performTap(service, tapX, tapY) {
                        mainHandler.postDelayed({
                            val currentClipboard = readClipboardText(appContext)
                            val copiedNow = !currentClipboard.isNullOrBlank() && currentClipboard != clipboardBeforeRun
                            if (copiedNow) {
                                finish(mapOf("status" to "success", "copiedText" to currentClipboard))
                                return@postDelayed
                            }

                            attemptCopy(index + 1)
                        }, 700L)
                    }
                }

                fun beginCopyFlow() {
                    mainHandler.postDelayed({
                        val rootAfterShare = service.rootInActiveWindow
                        if (rootAfterShare == null) {
                            finish(mapOf("status" to "error", "message" to "Share sheet not detected."))
                            return@postDelayed
                        }

                        if (!looksLikeShareSheet(rootAfterShare) && findCopyLinkNode(rootAfterShare) == null) {
                            // Still attempt copy taps; some share sheets hide labels until scrolled/tapped.
                            attemptCopy(0)
                            return@postDelayed
                        }

                        attemptCopy(0)
                    }, 850L)
                }

                fun attemptShare(index: Int) {
                    if (finished) return

                    val rootNow = service.rootInActiveWindow
                    if (rootNow != null) {
                        val shareNode = findShareNode(rootNow)
                        if (shareNode != null && performClick(shareNode)) {
                            beginCopyFlow()
                            return
                        }
                    }

                    if (index >= shareCandidates.size) {
                        val appHint = packageName ?: "current app"
                        finish(
                            mapOf(
                                "status" to "not_product",
                                "message" to "No Share button found on $appHint. Open a product detail page and try again."
                            )
                        )
                        return
                    }

                    val (tapX, tapY) = shareCandidates[index]
                    performTap(service, tapX, tapY) {
                        mainHandler.postDelayed({
                            val rootAfterTap = service.rootInActiveWindow
                            if (rootAfterTap != null && (looksLikeShareSheet(rootAfterTap) || findCopyLinkNode(rootAfterTap) != null)) {
                                beginCopyFlow()
                                return@postDelayed
                            }
                            attemptShare(index + 1)
                        }, 650L)
                    }
                }

                attemptShare(0)
            }

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                captureScreenSize(service) { width, height, _ ->
                    val useWidth = if (width > 0) width else fallbackSize.first
                    val useHeight = if (height > 0) height else fallbackSize.second
                    startFlowWithSize(useWidth, useHeight)
                }
            } else {
                startFlowWithSize(fallbackSize.first, fallbackSize.second)
            }
        }
    }

    private fun readClipboardText(context: Context): String? {
        val clipboard = context.getSystemService(Context.CLIPBOARD_SERVICE) as? ClipboardManager ?: return null
        val clip: ClipData? = clipboard.primaryClip
        val item = clip?.getItemAt(0) ?: return null
        return item.coerceToText(context)?.toString()
    }

    private fun findShareNode(root: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        return findFirst(root) { node ->
            val cd = node.contentDescription?.toString()?.lowercase().orEmpty()
            val text = node.text?.toString()?.lowercase().orEmpty()
            val id = node.viewIdResourceName?.lowercase().orEmpty()

            val shareKeywords = listOf(
                "share", "bagikan", "bagi", "share produk", "send", "kirim"
            )

            val idHints = listOf(
                "share", "btnshare", "ivshare", "action_share", "menu_share"
            )

            val looksLikeShare =
                shareKeywords.any { cd.contains(it) || text.contains(it) } ||
                    idHints.any { id.contains(it) }
            looksLikeShare
        }
    }

    private fun findCopyLinkNode(root: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        return findFirst(root) { node ->
            val cd = node.contentDescription?.toString()?.lowercase().orEmpty()
            val text = node.text?.toString()?.lowercase().orEmpty()
            val id = node.viewIdResourceName?.lowercase().orEmpty()

            val hasCopy =
                cd.contains("copy") || text.contains("copy") ||
                    cd.contains("salin") || text.contains("salin")
            val hasLink =
                cd.contains("link") || text.contains("link") ||
                    cd.contains("url") || text.contains("url") ||
                    cd.contains("tautan") || text.contains("tautan")

            val hasIdHint = id.contains("copy") || id.contains("clipboard") || id.contains("link")

            // Prefer explicit "copy link" but accept generic copy.
            (hasCopy && hasLink) || text == "copy" || cd == "copy" || text == "salin" || cd == "salin" || hasIdHint
        }
    }

    private fun buildShareCandidates(width: Int, height: Int, isTokopedia: Boolean): List<Pair<Float, Float>> {
        val w = width.toFloat().coerceAtLeast(1f)
        val h = height.toFloat().coerceAtLeast(1f)
        return if (isTokopedia) {
            listOf(
                Pair(w * 0.93f, h * 0.10f),
                Pair(w * 0.89f, h * 0.10f),
                Pair(w * 0.85f, h * 0.10f),
                Pair(w * 0.93f, h * 0.16f)
            )
        } else {
            listOf(
                Pair(w * 0.91f, h * 0.12f),
                Pair(w * 0.86f, h * 0.12f),
                Pair(w * 0.91f, h * 0.18f)
            )
        }
    }

    private fun buildCopyCandidates(width: Int, height: Int, isTokopedia: Boolean): List<Pair<Float, Float>> {
        val w = width.toFloat().coerceAtLeast(1f)
        val h = height.toFloat().coerceAtLeast(1f)
        return if (isTokopedia) {
            listOf(
                Pair(w * 0.50f, h * 0.74f),
                Pair(w * 0.50f, h * 0.80f),
                Pair(w * 0.50f, h * 0.86f),
                Pair(w * 0.75f, h * 0.80f),
                Pair(w * 0.25f, h * 0.80f)
            )
        } else {
            listOf(
                Pair(w * 0.50f, h * 0.76f),
                Pair(w * 0.50f, h * 0.84f),
                Pair(w * 0.75f, h * 0.82f),
                Pair(w * 0.25f, h * 0.82f)
            )
        }
    }

    private fun looksLikeShareSheet(root: AccessibilityNodeInfo): Boolean {
        val copyLinkNode = findCopyLinkNode(root)
        if (copyLinkNode != null) {
            copyLinkNode.recycle()
            return true
        }
        return findFirst(root) { node ->
            val cd = node.contentDescription?.toString()?.lowercase().orEmpty()
            val text = node.text?.toString()?.lowercase().orEmpty()
            val id = node.viewIdResourceName?.lowercase().orEmpty()

            val shareSheetKeywords = listOf(
                "copy", "salin", "link", "tautan", "bagikan", "share", "more", "lainnya"
            )
            shareSheetKeywords.any { cd.contains(it) || text.contains(it) || id.contains(it) }
        } != null
    }

    private fun looksLikeUrl(value: String): Boolean {
        val text = value.lowercase()
        return text.startsWith("http://") ||
            text.startsWith("https://") ||
            text.contains("tokopedia") ||
            text.contains("shopee") ||
            text.contains("lazada")
    }

    private fun screenSizeFromRoot(root: AccessibilityNodeInfo): Pair<Int, Int> {
        val rect = Rect()
        root.getBoundsInScreen(rect)
        val width = (rect.right - rect.left).coerceAtLeast(1)
        val height = (rect.bottom - rect.top).coerceAtLeast(1)
        return Pair(width, height)
    }

    private fun captureScreenSize(
        service: FraudAccessibilityService,
        callback: (Int, Int, String?) -> Unit
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.R) {
            callback(0, 0, "Screen capture fallback requires Android 11+.")
            return
        }

        service.takeScreenshot(
            Display.DEFAULT_DISPLAY,
            service.mainExecutor,
            object : AccessibilityService.TakeScreenshotCallback {
                override fun onSuccess(screenshot: AccessibilityService.ScreenshotResult) {
                    val hardwareBuffer = screenshot.hardwareBuffer
                    val width = hardwareBuffer.width
                    val height = hardwareBuffer.height
                    try {
                        hardwareBuffer.close()
                    } catch (_: Throwable) {
                    }
                    callback(width, height, null)
                }

                override fun onFailure(errorCode: Int) {
                    callback(0, 0, "Screenshot capture failed ($errorCode).")
                }
            }
        )
    }

    private fun performTap(
        service: FraudAccessibilityService,
        x: Float,
        y: Float,
        callback: (Boolean) -> Unit
    ) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) {
            callback(false)
            return
        }

        val path = Path().apply {
            moveTo(x, y)
        }
        val stroke = GestureDescription.StrokeDescription(path, 0, 75)
        val gesture = GestureDescription.Builder()
            .addStroke(stroke)
            .build()

        val dispatched = service.dispatchGesture(
            gesture,
            object : AccessibilityService.GestureResultCallback() {
                override fun onCompleted(gestureDescription: GestureDescription?) {
                    callback(true)
                }

                override fun onCancelled(gestureDescription: GestureDescription?) {
                    callback(false)
                }
            },
            null
        )

        if (!dispatched) {
            callback(false)
        }
    }

    private fun performClick(node: AccessibilityNodeInfo?): Boolean {
        if (node == null) return false
        try {
            if (node.isClickable) {
                return node.performAction(AccessibilityNodeInfo.ACTION_CLICK)
            }
            // Traverse the parent chain; each `.parent` call returns a new instance that must be recycled
            var current = node.parent
            while (current != null) {
                if (current.isClickable) {
                    val result = current.performAction(AccessibilityNodeInfo.ACTION_CLICK)
                    current.recycle()
                    return result
                }
                val next = current.parent
                current.recycle()
                current = next
            }
            return false
        } finally {
            // performClick takes ownership of node and always recycles it
            try { node.recycle() } catch (_: Throwable) {}
        }
    }

    private fun findFirst(root: AccessibilityNodeInfo, predicate: (AccessibilityNodeInfo) -> Boolean): AccessibilityNodeInfo? {
        val queue: ArrayDeque<AccessibilityNodeInfo> = ArrayDeque()
        queue.add(root)
        var found: AccessibilityNodeInfo? = null
        while (queue.isNotEmpty() && found == null) {
            val node = queue.removeFirst()
            val isRoot = node === root
            try {
                if (predicate(node)) {
                    found = node
                } else {
                    for (i in 0 until node.childCount) {
                        val child = node.getChild(i) ?: continue
                        queue.add(child)
                    }
                    if (!isRoot) {
                        node.recycle()
                    }
                }
            } catch (_: Throwable) {
                if (!isRoot) {
                    try { node.recycle() } catch (_: Throwable) {}
                }
            }
        }
        // Recycle nodes remaining in the queue.  This handles both early-exit
        // (found != null) and any partial traversal caused by an exception during
        // child iteration — in either case, already-queued children are cleaned up here.
        while (queue.isNotEmpty()) {
            val node = queue.removeFirst()
            if (node !== root && node !== found) {
                try { node.recycle() } catch (_: Throwable) {}
            }
        }
        return found
    }
}
