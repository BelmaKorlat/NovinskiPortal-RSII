# 1. Runtime slika (.NET Console)
FROM mcr.microsoft.com/dotnet/runtime:8.0 AS base
WORKDIR /app

# 2. Build faza
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Kopiramo .csproj fajlove iz svih povezanih projekata
COPY ["NovinskiPortal.Workers.Statistics/NovinskiPortal.Workers.Statistics.csproj", "NovinskiPortal.Workers.Statistics/"]
COPY ["NovinskiPortal.Services/NovinskiPortal.Services.csproj", "NovinskiPortal.Services/"]
COPY ["NovinskiPortal.Model/NovinskiPortal.Model.csproj", "NovinskiPortal.Model/"]
COPY ["NovinskiPortal.Common/NovinskiPortal.Common.csproj", "NovinskiPortal.Common/"]

RUN dotnet restore "NovinskiPortal.Workers.Statistics/NovinskiPortal.Workers.Statistics.csproj"

# Kopiramo ostatak koda
COPY . .
WORKDIR "/src/NovinskiPortal.Workers.Statistics"

# Build + publish
RUN dotnet publish "NovinskiPortal.Workers.Statistics.csproj" -c Release -o /app/publish /p:UseAppHost=false

# 3. Finalna faza (manja runtime slika)
FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .

# Pokretanje Workera
ENTRYPOINT ["dotnet", "NovinskiPortal.Workers.Statistics.dll"]
