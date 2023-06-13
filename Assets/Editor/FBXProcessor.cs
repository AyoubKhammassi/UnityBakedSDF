using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class FBXProcessor : AssetPostprocessor
{
    private void OnPreprocessModel()
    {
        if(assetPath.Contains("Encoded"))
        {
            ModelImporter modelImporter = assetImporter as ModelImporter;
            //BakedSDF meshes don't include normals or tangents
            modelImporter.importTangents = ModelImporterTangents.None;
            modelImporter.importNormals = ModelImporterNormals.None;
            modelImporter.materialImportMode = ModelImporterMaterialImportMode.None;
        }
    }



    void OnPostprocessModel(GameObject g)
    {
        if (assetPath.Contains("Encoded"))
        {
            Material BakedSDFMat = AssetDatabase.LoadAssetAtPath<Material>("Assets/Materials/BakedSDFMat.mat");
            MeshRenderer[] renderers = g.GetComponentsInChildren<MeshRenderer>();
            foreach (MeshRenderer r in renderers)
            {
                r.material = BakedSDFMat;
            }
        }


    }
}
