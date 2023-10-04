# apiVersion: v1
# kind: Namespace
# metadata:
#   name: <your-namespace-name>
# ---
# apiVersion: cert-manager.io/v1
# kind: ClusterIssuer
# metadata:
#   name: <your-selfsigned-issuer-name>
#   namespace: <your-namespace-name>
# spec:
#   selfSigned: {}
# ---
# apiVersion: cert-manager.io/v1
# kind: Certificate
# metadata:
#   name: <your-selfsigned-ca-name>
#   namespace: <your-namespace-name>
# spec:
#   isCA: true
#   commonName: <your-selfsigned-ca-name>
#   secretName: <your-root-secret-name>
#   privateKey:
#     algorithm: ECDSA
#     size: 256
#   issuerRef:
#     name: <your-selfsigned-issuer-name>
#     kind: ClusterIssuer
#     group: cert-manager.io
# ---
# apiVersion: cert-manager.io/v1
# kind: Issuer
# metadata:
#   name: <your-ca-issuer-name>
#   namespace: <your-namespace-name>
# spec:
#   ca:
#     secretName: <your-root-secret-name>