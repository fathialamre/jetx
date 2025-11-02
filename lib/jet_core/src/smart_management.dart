/// Defines how JetX manages the lifecycle and disposal of controllers and dependencies.
///
/// JetX automatically manages memory by disposing unused controllers based on the
/// selected SmartManagement mode. This helps prevent memory leaks while providing
/// flexibility for different application architectures.
///
/// ## Quick Guide
///
/// - **[SmartManagement.full]** (Default & Recommended) - Automatic disposal of all unused controllers
/// - **[SmartManagement.onlyBuilder]** - Only dispose controllers from builders/bindings
/// - **[SmartManagement.keepFactory]** - Dispose instances but keep factory for recreation
///
/// ## Usage
///
/// Set the mode globally in your app:
/// ```dart
/// void main() {
///   Jet.smartManagement = SmartManagement.full;
///   runApp(MyApp());
/// }
/// ```
///
/// ## Mode Details
///
/// ### [SmartManagement.full] (DEFAULT - Recommended)
///
/// **Behavior**: Automatically disposes ALL controllers that are not in use and not marked as permanent.
///
/// **When to use**:
/// - Default choice for most applications
/// - When you want full automatic memory management
/// - For apps with complex navigation and many controllers
///
/// **Example**:
/// ```dart
/// // Controllers are automatically disposed when routes are popped
/// class HomeController extends JetxController {
///   final count = 0.obs;
/// }
///
/// // On HomePage
/// Jet.put(HomeController()); // Created when page loads
///
/// // Navigate away
/// Jet.to(() => OtherPage()); // HomeController disposed automatically
///
/// // Navigate back
/// Jet.back(); // HomeController needs to be created again
/// ```
///
/// **Advantages**:
/// - Automatic memory management
/// - Prevents memory leaks
/// - Works with Jet.put(), Jet.lazyPut(), and Bindings
///
/// **Disadvantages**:
/// - Controllers are recreated when returning to routes
/// - State is lost unless persisted elsewhere
///
/// ---
///
/// ### [SmartManagement.onlyBuilder]
///
/// **Behavior**: Only disposes controllers created via Bindings or Jet.lazyPut().
/// Controllers created with Jet.put() or Jet.putAsync() are NOT automatically disposed.
///
/// **When to use**:
/// - When you need fine-grained control over disposal
/// - When mixing auto-disposed and manually-managed controllers
/// - For global controllers that should persist across navigation
///
/// **Example**:
/// ```dart
/// Jet.smartManagement = SmartManagement.onlyBuilder;
///
/// // This will NOT be auto-disposed (manual management required)
/// Jet.put(AuthController());
///
/// // This WILL be auto-disposed when route is removed
/// Jet.lazyPut(() => HomeController());
///
/// class HomeBinding extends Bindings {
///   @override
///   void dependencies() {
///     // This WILL be auto-disposed
///     Jet.lazyPut(() => ProfileController());
///   }
/// }
/// ```
///
/// **Advantages**:
/// - Explicit control over which controllers are managed
/// - Jet.put() controllers persist until manually deleted
/// - Good for hybrid manual/automatic management
///
/// **Disadvantages**:
/// - Must manually manage Jet.put() controllers to avoid leaks
/// - More complex memory management
/// - Easy to forget to clean up
///
/// **Best Practice**:
/// ```dart
/// // Global services - manual management
/// Jet.put(AuthService(), permanent: true);
/// Jet.put(ApiService(), permanent: true);
///
/// // Page controllers - automatic management
/// Jet.lazyPut(() => HomeController());
/// ```
///
/// ---
///
/// ### [SmartManagement.keepFactory]
///
/// **Behavior**: Disposes controller instances when not in use, but keeps the factory
/// function. Controllers are automatically recreated when accessed again.
///
/// **When to use**:
/// - When controllers can be safely recreated with their factory
/// - For stateless controllers that don't need persistence
/// - When you want automatic disposal but easy recreation
/// - Works great with fenix mode
///
/// **Example**:
/// ```dart
/// Jet.smartManagement = SmartManagement.keepFactory;
///
/// // Controller will be disposed but can be recreated
/// Jet.lazyPut(() => HomeController());
///
/// // On HomePage
/// final controller = Jet.find<HomeController>(); // Created
/// controller.updateData();
///
/// // Navigate away
/// Jet.to(() => OtherPage()); // Controller disposed, factory kept
///
/// // Navigate back
/// Jet.back();
/// final controller2 = Jet.find<HomeController>(); // Recreated from factory
/// // controller2 is a NEW instance (state is reset)
/// ```
///
/// **Advantages**:
/// - Automatic memory management
/// - Easy recreation without re-registration
/// - Works well with Jet.lazyPut()
/// - Reduced boilerplate
///
/// **Disadvantages**:
/// - State is lost on disposal (unless persisted)
/// - New instance on each recreation
///
/// **Best Practice with Fenix**:
/// ```dart
/// Jet.lazyPut(() => CacheController(), fenix: true);
/// // With fenix:true, factory is ALWAYS kept (same as SmartManagement.keepFactory)
/// // even if you use SmartManagement.full
/// ```
///
/// ---
///
/// ## Comparison Table
///
/// | Feature | full | onlyBuilder | keepFactory |
/// |---------|------|-------------|-------------|
/// | Auto-dispose Jet.put() | ✅ Yes | ❌ No | ✅ Yes |
/// | Auto-dispose Jet.lazyPut() | ✅ Yes | ✅ Yes | ✅ Yes |
/// | Auto-dispose Bindings | ✅ Yes | ✅ Yes | ✅ Yes |
/// | Keep factory after disposal | ❌ No | ❌ No | ✅ Yes |
/// | Memory efficient | ✅ High | ⚠️ Medium | ✅ High |
/// | Easy recreation | ❌ No | ❌ No | ✅ Yes |
/// | Default | ✅ | ❌ | ❌ |
///
/// ---
///
/// ## Common Patterns
///
/// ### Pattern 1: Global + Page Controllers
/// ```dart
/// // Recommended: Use default SmartManagement.full
/// Jet.smartManagement = SmartManagement.full;
///
/// // Global services (marked permanent)
/// Jet.put(AuthController(), permanent: true);
/// Jet.put(ThemeController(), permanent: true);
///
/// // Page controllers (auto-disposed)
/// Jet.lazyPut(() => HomeController());
/// Jet.lazyPut(() => ProfileController());
/// ```
///
/// ### Pattern 2: Manual Control
/// ```dart
/// Jet.smartManagement = SmartManagement.onlyBuilder;
///
/// // Manually managed
/// Jet.put(GlobalController());
///
/// // Auto-managed
/// Jet.lazyPut(() => PageController());
///
/// // Remember to clean up manually
/// @override
/// void onClose() {
///   Jet.delete<GlobalController>();
///   super.onClose();
/// }
/// ```
///
/// ### Pattern 3: Stateless Controllers
/// ```dart
/// Jet.smartManagement = SmartManagement.keepFactory;
///
/// // These can be recreated easily
/// Jet.lazyPut(() => UtilityController());
/// Jet.lazyPut(() => FormatterController());
/// ```
///
/// ---
///
/// ## Troubleshooting
///
/// **Problem**: Controllers not being disposed
/// - Check if marked as `permanent: true`
/// - Ensure using SmartManagement.full
/// - Verify controllers extend JetxController
///
/// **Problem**: Controllers recreated too often
/// - Consider using SmartManagement.keepFactory
/// - Or mark specific controllers as permanent
/// - Or use fenix mode: `Jet.lazyPut(() => C(), fenix: true)`
///
/// **Problem**: Memory leaks with SmartManagement.onlyBuilder
/// - Manually delete controllers created with Jet.put()
/// - Use permanent flag wisely
/// - Consider switching to SmartManagement.full
///
/// ---
///
/// ## See Also
/// - [Jet.put()] - Register a dependency immediately
/// - [Jet.lazyPut()] - Register a dependency lazily
/// - [Jet.delete()] - Manually delete a dependency
/// - [Bindings] - Group related dependencies
enum SmartManagement {
  /// **Default & Recommended**
  ///
  /// Automatically disposes ALL unused controllers and dependencies that are
  /// not marked as permanent. This provides full automatic memory management.
  ///
  /// Use this mode unless you have a specific reason to use another mode.
  full,

  /// **Manual + Automatic Hybrid**
  ///
  /// Only disposes controllers created via Bindings or [Jet.lazyPut()].
  /// Controllers created with [Jet.put()] or [Jet.putAsync()] are NOT disposed
  /// automatically and must be managed manually.
  ///
  /// Use this when you need explicit control over some controllers while
  /// having automatic management for others.
  onlyBuilder,

  /// **Factory Preservation**
  ///
  /// Disposes unused controllers but keeps their factory functions, allowing
  /// easy recreation when needed again. Similar to `full` but with the
  /// advantage of automatic recreation without re-registration.
  ///
  /// Use this for stateless controllers that can be safely recreated.
  keepFactory,
}
