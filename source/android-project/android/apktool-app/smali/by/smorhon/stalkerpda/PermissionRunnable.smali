.class public final Lby/smorhon/stalkerpda/PermissionRunnable;
.super Ljava/lang/Object;
.implements Ljava/lang/Runnable;
.source "PermissionRunnable.java"

.field private final activity:Lby/smorhon/stalkerpda/MainActivity;
.field private final request:Landroid/webkit/PermissionRequest;

.method public constructor <init>(Lby/smorhon/stalkerpda/MainActivity;Landroid/webkit/PermissionRequest;)V
    .locals 0
    invoke-direct {p0}, Ljava/lang/Object;-><init>()V
    iput-object p1, p0, Lby/smorhon/stalkerpda/PermissionRunnable;->activity:Lby/smorhon/stalkerpda/MainActivity;
    iput-object p2, p0, Lby/smorhon/stalkerpda/PermissionRunnable;->request:Landroid/webkit/PermissionRequest;
    return-void
.end method

.method public run()V
    .locals 2
    iget-object v0, p0, Lby/smorhon/stalkerpda/PermissionRunnable;->activity:Lby/smorhon/stalkerpda/MainActivity;
    iget-object v1, p0, Lby/smorhon/stalkerpda/PermissionRunnable;->request:Landroid/webkit/PermissionRequest;
    invoke-virtual {v0, v1}, Lby/smorhon/stalkerpda/MainActivity;->handleWebPermission(Landroid/webkit/PermissionRequest;)V
    return-void
.end method
